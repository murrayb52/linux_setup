#!/bin/bash
# Author: Murray Buchanan
# Polybar launch script with selectable themes

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Set the polybar option to use (can be changed to: Option1, Option2, Option3 - Nordic, or Option4-Green)
# Default: Option4-Green
POLYBAR_OPTION="${POLYBAR_OPTION:-Option4-Green}"

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if the selected option directory exists
if [ ! -d "$SCRIPT_DIR/$POLYBAR_OPTION" ]; then
    echo "Error: Polybar option '$POLYBAR_OPTION' not found!"
    echo "Available options:"
    ls -d "$SCRIPT_DIR"/Option* 2>/dev/null | xargs -n 1 basename
    exit 1
fi

# Check if the config file exists
if [ ! -f "$SCRIPT_DIR/$POLYBAR_OPTION/config" ]; then
    echo "Error: Config file not found in $SCRIPT_DIR/$POLYBAR_OPTION/"
    exit 1
fi

# Launch Polybar with the selected config
echo "Launching Polybar with $POLYBAR_OPTION theme..."

# Different options have different bar configurations
case "$POLYBAR_OPTION" in
    "Option4-Green"|"Option3 - Nordic")
        # Get primary monitor (usually laptop screen)
        PRIMARY=$(xrandr --query | grep " connected primary" | cut -d" " -f1)
        
        # Launch main bars on primary monitor
        MONITOR=$PRIMARY polybar -c "$SCRIPT_DIR/$POLYBAR_OPTION/config" main &
        MONITOR=$PRIMARY polybar -c "$SCRIPT_DIR/$POLYBAR_OPTION/config" bottom &
        
        # Launch simple workspace bar on external monitors
        for monitor in $(xrandr --query | grep " connected" | grep -v "primary" | cut -d" " -f1); do
            MONITOR=$monitor polybar -c "$SCRIPT_DIR/$POLYBAR_OPTION/config" external &
        done
        ;;
    *)
        # For Option1 and Option2, launch just the main bar
        polybar -c "$SCRIPT_DIR/$POLYBAR_OPTION/config" main &
        ;;
esac

echo "Polybar launched successfully!"
