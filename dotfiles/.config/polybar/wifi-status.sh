#!/bin/bash
# WiFi status indicator for polybar.
#
# Shows a distinct icon per state, not just a colour change on the same
# glyph: FontAwesome 4 (this bar's main icon font) has only one generic
# "wifi" icon with no on/off/connected variants, so these come from Hack
# Nerd Font's bundled Material Design Icons instead (bar/main font-2,
# selected inline via %{T3}, reset with %{T-}).
#
# wifi-off / wifi (solid) / wifi-strength-outline - codepoints confirmed
# directly from the installed font's cmap (fontTools), not guessed.

WIFI_STATUS=$(nmcli radio wifi)

if [ "$WIFI_STATUS" = "disabled" ]; then
    echo "%{T3}%{F#666666}󰖪%{F-}%{T-}"
    exit 0
fi

# Get current connection
CONNECTED=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)

if [ -n "$CONNECTED" ]; then
    # Connected - solid wifi icon, intense green (matches the bar's
    # accent green border, boosted saturation so it reads as vivid at
    # small icon/text size rather than duller than a solid-filled block)
    echo "%{T3}%{F#3cc431}󰖩%{F-}%{T-}"
else
    # On but not connected - hollow/outline wifi icon, white
    echo "%{T3}%{F#ffffff}󰤯%{F-}%{T-}"
fi
