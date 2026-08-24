#!/bin/bash
# WiFi status indicator for polybar

# Check if WiFi is enabled
WIFI_STATUS=$(nmcli radio wifi)

if [ "$WIFI_STATUS" = "disabled" ]; then
    echo "%{F#666666}WiFi%{F-}"
    exit 0
fi

# Get current connection
CONNECTED=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)

if [ -n "$CONNECTED" ]; then
    # Connected - show the bar's accent green (matches config_Option5's
    # ${color.accent}, e.g. the lid/power menu border)
    echo "%{F#548550}WiFi%{F-}"
else
    # On but not connected - show white
    echo "%{F#ffffff}WiFi%{F-}"
fi
