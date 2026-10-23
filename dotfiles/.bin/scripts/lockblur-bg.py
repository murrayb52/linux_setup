#!/usr/bin/env python3
# Builds the lock-screen image for lockblur.sh: a blurred, dimmed screenshot with a
# frosted-glass padlock badge centred on each monitor, so it's obvious the screen is
# locked. Writes it raw in i3lock's "native" pixel format (the same as cairo RGB24)
# to OUT and prints the matching --raw argument, e.g. "1920x1200:native".
# Skipping PNG encode/decode and blurring a shrunken copy keeps this to ~0.2s.
# DEPENDENCIES: python3-pil, python3-cairo, xrandr
# Usage: lockblur-bg.py OUT
import math
import re
import subprocess
import sys

import cairo
from PIL import ImageFilter, ImageGrab

SHRINK = 4      # blur a 1/4-size copy: same look, a fraction of the work
BLUR = 3        # gaussian radius at that size
DIM = 0.88      # brightness multiplier
BADGE_R = 76    # px; sits just inside i3lock's own indicator ring (radius 90, width 10)


def monitors(xrandr):
    """(x, y, w, h) of each active monitor, as i3lock centres its ring on each one."""
    out = xrandr.communicate()[0]
    return [(int(x), int(y), int(w), int(h))
            for w, h, x, y in re.findall(r"(\d+)/\d+x(\d+)/\d+\+(\d+)\+(\d+)", out)]


def badge(ctx, cx, cy, R):
    pad = R * 0.16

    # soft shadow so the badge still reads over pale backgrounds
    shadow = cairo.RadialGradient(cx, cy + R * 0.03, R * 0.9, cx, cy + R * 0.03, R + pad)
    shadow.add_color_stop_rgba(0, 0, 0, 0, 0.28)
    shadow.add_color_stop_rgba(1, 0, 0, 0, 0)
    ctx.arc(cx, cy, R + pad, 0, 2 * math.pi)
    ctx.set_source(shadow)
    ctx.fill()

    # frosted disc: translucent white, a touch brighter at the top like lit glass
    glass = cairo.LinearGradient(0, cy - R, 0, cy + R)
    glass.add_color_stop_rgba(0, 1, 1, 1, 0.30)
    glass.add_color_stop_rgba(1, 1, 1, 1, 0.16)
    ctx.arc(cx, cy, R, 0, 2 * math.pi)
    ctx.set_source(glass)
    ctx.fill()

    # crisp rim
    lw = max(1.5, R * 0.03)
    ctx.set_line_width(lw)
    ctx.arc(cx, cy, R - lw / 2, 0, 2 * math.pi)
    ctx.set_source_rgba(1, 1, 1, 0.55)
    ctx.stroke()

    # padlock, drawn in its own group so the keyhole can be cut out to show the glass;
    # the body sits a little low to balance the shackle
    bw, bh, br = R * 0.70, R * 0.54, R * 0.10
    bx, by = cx - bw / 2, cy - R * 0.06
    ctx.push_group()
    ctx.set_source_rgba(1, 1, 1, 1)

    # shackle: an arch whose legs run down into the body
    sr = bw * 0.30
    ctx.set_line_width(R * 0.12)
    ctx.move_to(cx - sr, by + bh * 0.2)
    ctx.line_to(cx - sr, by - R * 0.16)
    ctx.arc(cx, by - R * 0.16, sr, math.pi, 2 * math.pi)
    ctx.line_to(cx + sr, by + bh * 0.2)
    ctx.stroke()

    # body
    ctx.new_sub_path()
    ctx.arc(bx + bw - br, by + br, br, -math.pi / 2, 0)
    ctx.arc(bx + bw - br, by + bh - br, br, 0, math.pi / 2)
    ctx.arc(bx + br, by + bh - br, br, math.pi / 2, math.pi)
    ctx.arc(bx + br, by + br, br, math.pi, 3 * math.pi / 2)
    ctx.close_path()
    ctx.fill()

    # keyhole
    kr = R * 0.075
    ky = by + bh * 0.42
    ctx.set_operator(cairo.OPERATOR_CLEAR)
    ctx.arc(cx, ky, kr, 0, 2 * math.pi)
    ctx.fill()
    ctx.rectangle(cx - kr * 0.45, ky, kr * 0.9, bh * 0.32)
    ctx.fill()

    ctx.pop_group_to_source()
    ctx.paint_with_alpha(0.95)


# xrandr takes ~60ms, so let it run while we grab and blur
xrandr = subprocess.Popen(["xrandr", "--listactivemonitors"], stdout=subprocess.PIPE, text=True)

shot = ImageGrab.grab()
w, h = shot.size
small = (shot.reduce(SHRINK)
         .filter(ImageFilter.GaussianBlur(BLUR))
         .point(lambda v: int(v * DIM)))

# BGRX bytes are cairo's RGB24 (and i3lock's "native") layout on little-endian
sw, sh = small.size
src = cairo.ImageSurface.create_for_data(
    bytearray(small.tobytes("raw", "BGRX")), cairo.FORMAT_RGB24, sw, sh, sw * 4)
surf = cairo.ImageSurface(cairo.FORMAT_RGB24, w, h)
ctx = cairo.Context(surf)

# scale the blurred copy back up to full size
ctx.save()
ctx.scale(w / sw, h / sh)
ctx.set_source_surface(src)
ctx.get_source().set_filter(cairo.FILTER_BILINEAR)
ctx.get_source().set_extend(cairo.EXTEND_PAD)
ctx.paint()
ctx.restore()

for mx, my, mw, mh in monitors(xrandr) or [(0, 0, w, h)]:
    badge(ctx, mx + mw / 2, my + mh / 2, BADGE_R)
surf.flush()

with open(sys.argv[1], "wb") as f:
    f.write(surf.get_data())
print(f"{w}x{h}:native")
