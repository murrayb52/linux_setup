#!/bin/bash
# Bluetooth status indicator for polybar.
#
# Shows a distinct icon per state, not just a colour change on the same
# glyph: FontAwesome 4 (this bar's main icon font) has only a generic
# "bluetooth" icon with no on/off/connected variants, so these come from
# Hack Nerd Font's bundled Material Design Icons instead (bar/main
# font-2, selected inline via %{T3}, reset with %{T-}).
#
# bluetooth-off / bluetooth / bluetooth-connect - codepoints confirmed
# directly from the installed font's cmap (fontTools), not guessed.

BT_POWER=$(bluetoothctl show 2>/dev/null | grep "Powered" | awk '{print $2}')

if [ "$BT_POWER" != "yes" ]; then
    echo "%{T3}%{F#666666}󰂲%{F-}%{T-}"
    exit 0
fi

# Get connected devices count
CONNECTED_COUNT=$(bluetoothctl devices Connected 2>/dev/null | wc -l)

if [ "$CONNECTED_COUNT" -gt 0 ]; then
    # Connected - bluetooth-connect icon, intense green (matches the
    # bar's accent green border, boosted saturation so it reads as vivid
    # at small icon/text size rather than duller than a solid-filled block)
    echo "%{T3}%{F#3cc431}󰂱%{F-}%{T-}"
else
    # On but not connected - plain bluetooth icon, white
    echo "%{T3}%{F#ffffff}󰂯%{F-}%{T-}"
fi
