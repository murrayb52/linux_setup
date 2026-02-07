#!/bin/bash

# SCRIPT FOR [PIXELATED] i3lock CONFIGURATION
# DEPENDENCIES: imagemagick, scrot, i3lock
# Author: Murray Buchanan
ICON=$HOME/.xlock/lock9.png
TMPBG=/tmp/screen.png
TEXT=/tmp/locktext.png

scrot /tmp/screen.png
convert $TMPBG -scale 10% -scale 1000% $TMPBG
[ -f $TEXT ] || { 
    convert -size 3000x60 xc:white -font Z003 -pointsize 26 -fill black -gravity center -annotate +0+0 'Locked' $TEXT;
    convert $TEXT -alpha set -channel A -evaluate set 50% $TEXT; 
}
convert $TMPBG $ICON -gravity center -composite -matte $TMPBG
convert $TMPBG $TEXT -gravity center -geometry +0+200 -composite $TMPBG

i3lock -b -f -i $TMPBG
rm $TMPBG
rm $TEXT
