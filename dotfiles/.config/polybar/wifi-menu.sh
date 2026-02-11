#!/bin/bash
# WiFi menu script for polybar using rofi

# Get WiFi interface
WIFI_INTERFACE=$(nmcli device status | awk '/wifi/ {print $1; exit}')

if [ -z "$WIFI_INTERFACE" ]; then
    notify-send "WiFi Error" "No WiFi interface found"
    exit 1
fi

# Check if WiFi is enabled
WIFI_STATUS=$(nmcli radio wifi)

# Build the menu
if [ "$WIFI_STATUS" = "enabled" ]; then
    # Get current connection
    CURRENT=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
    
    # Create menu options
    MENU=" Turn Off WiFi\n"
    
    if [ -n "$CURRENT" ]; then
        MENU+=" Disconnect from $CURRENT\n"
        MENU+="---\n"
    fi
    
    # Get available networks with signal strength (using cached scan)
    NETWORKS=$(nmcli -f SSID,SIGNAL,SECURITY device wifi list | tail -n +2 | \
        awk '{
            ssid=""; 
            for(i=1; i<NF-1; i++) ssid=ssid $i" "; 
            signal=$(NF-1); 
            security=$NF;
            gsub(/^ +| +$/, "", ssid);
            if(ssid != "" && ssid != "--") {
                icon="";
                if(signal >= 75) icon="";
                else if(signal >= 50) icon="";
                else if(signal >= 25) icon="";
                lock="";
                if(security != "--") lock=" ";
                printf "%s %s%s (%d%%)\n", icon, ssid, lock, signal;
            }
        }' | sort -u)
    
    if [ -n "$CURRENT" ]; then
        # Highlight current network
        MENU+=$(echo "$NETWORKS" | sed "s/\(.*$CURRENT.*\)/ \1/")
    else
        MENU+="$NETWORKS"
    fi
else
    MENU=" Turn On WiFi"
fi

# Show rofi menu at top right
CHOICE=$(echo -e "$MENU" | rofi -dmenu -i -p "WiFi" -location 3 -xoffset -10 -yoffset 50 -theme-str 'window {width: 400px;}' -theme-str 'listview {lines: 10;}')

if [ -z "$CHOICE" ]; then
    exit 0
fi

# Handle selection
if [[ "$CHOICE" == *"Turn Off WiFi"* ]]; then
    nmcli radio wifi off
    notify-send "WiFi" "WiFi disabled"
elif [[ "$CHOICE" == *"Turn On WiFi"* ]]; then
    nmcli radio wifi on
    notify-send "WiFi" "WiFi enabled"
elif [[ "$CHOICE" == *"Disconnect"* ]]; then
    nmcli connection down "$CURRENT"
    notify-send "WiFi" "Disconnected from $CURRENT"
else
    # Extract SSID from choice (remove icon and signal info)
    SSID=$(echo "$CHOICE" | sed -E 's/^[^ ]+ //; s/ 󰌾 / /; s/ \([0-9]+%\)$//')
    SSID=$(echo "$SSID" | xargs)  # Trim whitespace
    
    # Check if network requires password
    if [[ "$CHOICE" == *""* ]]; then
        PASSWORD=$(rofi -dmenu -password -p "Password for $SSID")
        if [ -n "$PASSWORD" ]; then
            nmcli device wifi connect "$SSID" password "$PASSWORD"
            if [ $? -eq 0 ]; then
                notify-send "WiFi" "Connected to $SSID"
            else
                notify-send "WiFi Error" "Failed to connect to $SSID"
            fi
        fi
    else
        nmcli device wifi connect "$SSID"
        if [ $? -eq 0 ]; then
            notify-send "WiFi" "Connected to $SSID"
        else
            notify-send "WiFi Error" "Failed to connect to $SSID"
        fi
    fi
fi
