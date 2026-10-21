#!/bin/bash

# SCRIPT FOR [BLURRED] i3lock CONFIGURATION
# Locks over a blurred, dimmed screenshot so the desktop looks frosted behind it
# DEPENDENCIES: scrot, ffmpeg, i3lock
SHOT=$(mktemp --suffix=.png)
TMPBG=$(mktemp --suffix=.png)

scrot -o "$SHOT"
ffmpeg -loglevel error -y -i "$SHOT" -vf "gblur=sigma=12,eq=brightness=-0.12" "$TMPBG"

i3lock -e -f -i "$TMPBG"
rm -f "$SHOT" "$TMPBG"
