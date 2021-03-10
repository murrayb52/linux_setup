#Taken from: https://github.com/reedrw/dotfiles/blob/master/config/polybar/playpause.sh

#!/bin/sh

if ! mpc status | grep -q "playing"; then
    echo ""
else
    echo ""
fi
