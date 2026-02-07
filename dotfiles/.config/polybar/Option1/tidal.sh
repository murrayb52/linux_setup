#!/bin/bash
# Godkayaki ~
# Show Tidal current song without mpd or any extra application other than Tidal.

if pgrep -x "tidal-hifi" > /dev/null; then
    artist=`playerctl --player=tidal-hifi metadata artist`
    title=`playerctl --player=tidal-hifi metadata title`
    echo "" $artist "-" $title
else
    echo ""
fi
