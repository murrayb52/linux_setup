#!/bin/bash
# Get cursor position
eval $(xdotool getmouselocation --shell)
# Open rofi just below cursor and paste selected item
SELECTION=$(clipster -o -n 20 | rofi -dmenu -p "📋 Clipboard" -i -location 0 -xoffset $((X - 300)) -yoffset $((Y + 20)) -theme-str 'window {width: 600px;}')
if [ -n "$SELECTION" ]; then
    echo -n "$SELECTION" | xclip -selection clipboard
    xdotool key --clearmodifiers shift+Insert
fi
