#!/bin/bash
# Author: Murray Buchanan
# Polybar launch script: starts the main (top) and bottom bars from config.ini
# on every connected monitor.

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

CONFIG="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/config.ini"

# main/bottom have no fixed `monitor =` line, so they follow MONITOR. Start the
# primary monitor (usually the laptop panel) first, then mirror both bars onto
# any other connected screen.
PRIMARY=$(xrandr --query | grep " connected primary" | cut -d" " -f1)
OTHERS=$(xrandr --query | grep " connected" | grep -v "primary" | cut -d" " -f1)

for monitor in $PRIMARY $OTHERS; do
    MONITOR=$monitor polybar -c "$CONFIG" main &
    MONITOR=$monitor polybar -c "$CONFIG" bottom &
done
