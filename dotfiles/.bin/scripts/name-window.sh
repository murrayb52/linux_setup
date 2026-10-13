#!/usr/bin/env bash
# Prompt for a custom name and apply it as title_format to the focused window.
# Empty input resets to the plain window title (%title).

WIN_ID=$(xdotool getactivewindow 2>/dev/null)
if [ -z "$WIN_ID" ]; then
    notify-send "name-window" "Could not get focused window ID" -t 3000
    exit 1
fi

NEW_NAME=$(rofi -dmenu -p "Window name:" -theme-str 'window {width: 450px;} listview {lines: 0;}' < /dev/null)

# Cancelled (Escape) — do nothing
[ $? -ne 0 ] && exit 0

if [ -z "$NEW_NAME" ]; then
    # Empty — reset to bare window title
    i3-msg "[id=\"$WIN_ID\"] title_format \"%title\""
else
    i3-msg "[id=\"$WIN_ID\"] title_format \"$NEW_NAME\""
fi
