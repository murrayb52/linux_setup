#!/bin/bash
# Author: Murray Buchanan
# Polybar launch script with selectable themes

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Set the polybar option to use (can be changed to: Option1, Option2, Option3, Option4, or Option5)
# Default: Option5
POLYBAR_OPTION="${POLYBAR_OPTION:-Option5}"

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if the config file exists
if [ ! -f "$SCRIPT_DIR/config_${POLYBAR_OPTION}" ]; then
    echo "Error: Config file not found: $SCRIPT_DIR/config_${POLYBAR_OPTION}"
    echo "Available options:"
    ls "$SCRIPT_DIR"/config_Option* 2>/dev/null | sed 's/.*config_//' | sed 's/Option/  Option/'
    exit 1
fi

# Launch Polybar with the selected config
echo "Launching Polybar with ${POLYBAR_OPTION} theme..."

# Different options have different bar configurations
case "$POLYBAR_OPTION" in
    "Option5"|"Option4"|"Option3")
        # Get primary monitor (usually laptop screen)
        PRIMARY=$(xrandr --query | grep " connected primary" | cut -d" " -f1)
        
        # Launch main bars on primary monitor
        MONITOR=$PRIMARY polybar -c "$SCRIPT_DIR/config_${POLYBAR_OPTION}" main &
        MONITOR=$PRIMARY polybar -c "$SCRIPT_DIR/config_${POLYBAR_OPTION}" bottom &
        
        # Mirror the same main/bottom bars onto external monitors (only Option4
        # and Option5 have the external-monitor loop). main/bottom have no
        # `monitor =` line in the config, so they follow whatever MONITOR is
        # set to here, same as the laptop panel gets.
        if [ "$POLYBAR_OPTION" = "Option4" ] || [ "$POLYBAR_OPTION" = "Option5" ]; then
            for monitor in $(xrandr --query | grep " connected" | grep -v "primary" | cut -d" " -f1); do
                MONITOR=$monitor polybar -c "$SCRIPT_DIR/config_${POLYBAR_OPTION}" main &
                MONITOR=$monitor polybar -c "$SCRIPT_DIR/config_${POLYBAR_OPTION}" bottom &
            done
        fi
        ;;
    *)
        # For Option1 and Option2, launch just the main bar
        polybar -c "$SCRIPT_DIR/config_${POLYBAR_OPTION}" main &
        ;;
esac

echo "Polybar launched successfully!"
