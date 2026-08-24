#!/bin/bash
# Bluetooth status indicator for polybar

# Check if bluetooth is powered
BT_POWER=$(bluetoothctl show 2>/dev/null | grep "Powered" | awk '{print $2}')

if [ "$BT_POWER" != "yes" ]; then
    echo "%{F#666666}BT%{F-}"
    exit 0
fi

# Get connected devices count
CONNECTED_COUNT=$(bluetoothctl devices Connected 2>/dev/null | wc -l)

if [ "$CONNECTED_COUNT" -gt 0 ]; then
    # Connected - show the bar's accent green (matches config_Option5's
    # ${color.accent}, e.g. the lid/power menu border)
    echo "%{F#548550}BT%{F-}"
else
    # On but not connected - show white
    echo "%{F#ffffff}BT%{F-}"
fi
