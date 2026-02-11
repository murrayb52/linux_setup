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
    # Connected - show bright green
    echo "%{F#00ff00}WiFi%{F-}"
else
    # On but not connected - show white
    echo "%{F#ffffff}WiFi%{F-}"
fi
