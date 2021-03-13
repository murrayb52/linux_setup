#!/bin/bash

player_status=$(playerctl -p spotify status 2> /dev/null)

if [ "$player_status" = "Playing" ]; then
	if [[ $(playerctl -p spotify metadata --format "{{artist}}" 2> /dev/null) ]]; then
		echo "$(playerctl -p spotify metadata --format "{{artist}} - {{title}}" 2> /dev/null)"
	else
		echo "$(playerctl -p spotify metadata --format "{{title}}" 2> /dev/null)"
	fi
elif [ "$player_status" = "Paused" ]; then
    echo "Paused"
else
    echo ""
fi
