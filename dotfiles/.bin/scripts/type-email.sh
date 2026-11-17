#!/usr/bin/env bash
# Type my email address into the focused window (bound to $mod+Shift+t in i3).
# The address lives in ~/.config/private/email so it never gets committed.

EMAIL_FILE="$HOME/.config/private/email"

if [ ! -s "$EMAIL_FILE" ]; then
    notify-send "type-email" "Missing or empty $EMAIL_FILE" -t 4000
    exit 1
fi

# --clearmodifiers drops any Super/Shift still held from the shortcut.
# head -n1 + tr strip the trailing newline so Enter isn't sent after the address.
xdotool type --clearmodifiers --delay 30 -- "$(head -n1 "$EMAIL_FILE" | tr -d '\r\n')"
