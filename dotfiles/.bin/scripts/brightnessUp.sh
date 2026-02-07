#!/bin/bash
# Author: Murray Buchanan
# This script increases screen brightness 
brightness=$(xrandr --verbose | grep "Brightness: " | cut -d " " -f 2)

# xrandr --verbose | grep "Brightness: " | cut -d " " -f 2 returns just the number

#echo "Input: $brightness"

if [ $(echo "$brightness >= 1.0" | bc -l) -eq 1 ]
then
	new_brightness=1.0
else
	new_brightness=$(echo "$brightness + 0.1" | bc -l)    
fi

xrandr --output eDP-1 --brightness $new_brightness
