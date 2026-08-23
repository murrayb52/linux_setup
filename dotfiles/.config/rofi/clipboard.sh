#!/bin/bash
SELECTION=$(clipster -o -n 20 | rofi -dmenu -p "📋 Clipboard" -i -location 0 -theme-str 'window {width: 600px; x-offset: 0; y-offset: 0; location: center;}')
if [ -n "$SELECTION" ]; then
    echo -n "$SELECTION" | xclip -selection clipboard
    xdotool key --clearmodifiers shift+Insert
fi
