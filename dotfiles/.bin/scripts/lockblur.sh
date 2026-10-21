#!/bin/bash

# SCRIPT FOR [BLURRED] i3lock CONFIGURATION
# Locks over a blurred, dimmed screenshot so the desktop looks frosted behind it.
# Falls back to a plain black lock if the screenshot or blur fails.
# DEPENDENCIES: scrot, ffmpeg, i3lock
SHOT=$(mktemp --suffix=.png)
TMPBG=$(mktemp --suffix=.png)
trap 'rm -f "$SHOT" "$TMPBG"' EXIT INT TERM

if scrot -o "$SHOT" \
    && ffmpeg -loglevel error -y -i "$SHOT" -vf "gblur=sigma=12,eq=brightness=-0.12" "$TMPBG" \
    && [ -s "$TMPBG" ]; then
    # drop the unblurred capture as soon as it has served its purpose
    rm -f "$SHOT"
    i3lock -e -f -i "$TMPBG" || i3lock -e -f -c 000000
else
    i3lock -e -f -c 000000
fi
