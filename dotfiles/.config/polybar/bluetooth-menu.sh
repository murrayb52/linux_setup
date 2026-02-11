#!/bin/bash
# Bluetooth menu script for polybar using rofi

# Check if bluetooth is powered
BT_POWER=$(bluetoothctl show | grep "Powered" | awk '{print $2}')

# Build the menu
if [ "$BT_POWER" = "yes" ]; then
    # Get paired devices
    MENU=" Turn Off Bluetooth\n"
    MENU+="---\n"
    
    # Get connected devices
    CONNECTED=$(bluetoothctl devices Connected | cut -d' ' -f2-)
    if [ -n "$CONNECTED" ]; then
        while IFS= read -r device; do
            MAC=$(echo "$device" | awk '{print $1}')
            NAME=$(echo "$device" | cut -d' ' -f2-)
            MENU+="  $NAME (Connected)\n"
        done <<< "$CONNECTED"
        MENU+="---\n"
    fi
    
    # Start scan in background (non-blocking)
    bluetoothctl scan on >/dev/null 2>&1 &
    SCAN_PID=$!
    
    # Get all paired devices
    PAIRED=$(bluetoothctl devices Paired)
    if [ -n "$PAIRED" ]; then
        MENU+="Paired Devices:\n"
        while IFS= read -r device; do
            MAC=$(echo "$device" | awk '{print $2}')
            NAME=$(echo "$device" | cut -d' ' -f3-)
            
            # Check if connected
            IS_CONNECTED=$(echo "$CONNECTED" | grep -c "$MAC")
            if [ "$IS_CONNECTED" -eq 0 ]; then
                # Check device type for icon
                INFO=$(bluetoothctl info "$MAC" 2>/dev/null)
                ICON=""
                if echo "$INFO" | grep -qi "audio"; then
                    ICON=""
                elif echo "$INFO" | grep -qi "phone"; then
                    ICON=""
                elif echo "$INFO" | grep -qi "keyboard"; then
                    ICON=""
                elif echo "$INFO" | grep -qi "mouse"; then
                    ICON=""
                fi
                MENU+="$ICON $NAME\n"
            fi
        done <<< "$PAIRED"
        MENU+="---\n"
    fi
    
    # Get available devices
    AVAILABLE=$(bluetoothctl devices | grep -v "Paired")
    if [ -n "$AVAILABLE" ]; then
        MENU+="Available Devices:\n"
        while IFS= read -r device; do
            MAC=$(echo "$device" | awk '{print $2}')
            NAME=$(echo "$device" | cut -d' ' -f3-)
            MENU+=" $NAME (New)\n"
        done <<< "$AVAILABLE"
    fi
else
    MENU=" Turn On Bluetooth"
fi

# Kill background scan
kill $SCAN_PID 2>/dev/null

# Show rofi menu at top right
CHOICE=$(echo -e "$MENU" | rofi -dmenu -i -p "Bluetooth" -location 3 -xoffset -10 -yoffset 50 -theme-str 'window {width: 400px;}' -theme-str 'listview {lines: 10;}')

if [ -z "$CHOICE" ]; then
    bluetoothctl scan off >/dev/null 2>&1
    exit 0
fi

# Handle selection
if [[ "$CHOICE" == *"Turn Off Bluetooth"* ]]; then
    bluetoothctl power off
    notify-send "Bluetooth" "Bluetooth disabled"
elif [[ "$CHOICE" == *"Turn On Bluetooth"* ]]; then
    bluetoothctl power on
    notify-send "Bluetooth" "Bluetooth enabled"
elif [[ "$CHOICE" == *"(Connected)"* ]]; then
    # Disconnect device
    NAME=$(echo "$CHOICE" | sed -E 's/^[^ ]+ +//; s/ \(Connected\)$//')
    MAC=$(bluetoothctl devices Connected | grep "$NAME" | awk '{print $2}')
    if [ -n "$MAC" ]; then
        bluetoothctl disconnect "$MAC"
        notify-send "Bluetooth" "Disconnected from $NAME"
    fi
else
    # Connect to device
    NAME=$(echo "$CHOICE" | sed -E 's/^[^ ]+ //')
    NAME=$(echo "$NAME" | sed 's/ (New)$//')
    NAME=$(echo "$NAME" | xargs)
    
    # Find MAC address
    MAC=$(bluetoothctl devices | grep "$NAME" | awk '{print $2}')
    
    if [ -n "$MAC" ]; then
        # Check if device is paired
        IS_PAIRED=$(bluetoothctl devices Paired | grep -c "$MAC")
        
        if [ "$IS_PAIRED" -eq 0 ]; then
            notify-send "Bluetooth" "Pairing with $NAME..."
            bluetoothctl pair "$MAC"
            sleep 2
            bluetoothctl trust "$MAC"
        fi
        
        notify-send "Bluetooth" "Connecting to $NAME..."
        bluetoothctl connect "$MAC"
        
        if [ $? -eq 0 ]; then
            notify-send "Bluetooth" "Connected to $NAME"
        else
            notify-send "Bluetooth Error" "Failed to connect to $NAME"
        fi
    fi
fi
