#!/bin/bash
# Author: Murray Buchanan
# This script decreases screen brightness 
brightness=$(xrandr --verbose | grep "Brightness: " | cut -d " " -f 2)

# xrandr --verbose | grep "Brightness: " | cut -d " " -f 2 returns just the number

if [ $(echo "$brightness <= 0.1" | bc -l) -eq 1 ]
then
	new_brightness=0.1
else
	new_brightness=$(echo "$brightness - 0.1" | bc -l)    
fi

xrandr --output eDP-1 --brightness $new_brightness
