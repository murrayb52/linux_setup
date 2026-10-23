#!/bin/bash

# SCRIPT FOR [BLURRED] i3lock CONFIGURATION
# Locks over a blurred, dimmed screenshot so the desktop looks frosted behind it.
# Falls back to a plain black lock if the screenshot or blur fails.
# Run by xss-lock (--transfer-sleep-lock), so it also locks before suspend/lid close.
# DEPENDENCIES: scrot, ffmpeg, i3lock
SHOT=$(mktemp --suffix=.png)
TMPBG=$(mktemp --suffix=.png)
trap 'rm -f "$SHOT" "$TMPBG"' EXIT INT TERM

# i3lock forks once it holds the screen, so when this returns we're locked
lock() {
    if [[ -e /dev/fd/${XSS_SLEEP_LOCK_FD:--1} ]]; then
        # keep xss-lock's sleep delay lock out of the forked i3lock
        i3lock "$@" {XSS_SLEEP_LOCK_FD}<&-
    else
        i3lock "$@"
    fi
}

if scrot -o "$SHOT" \
    && ffmpeg -loglevel error -y -i "$SHOT" -vf "gblur=sigma=12,eq=brightness=-0.12" "$TMPBG" \
    && [ -s "$TMPBG" ]; then
    # drop the unblurred capture as soon as it has served its purpose
    rm -f "$SHOT"
    lock -e -f -i "$TMPBG" || lock -e -f -c 000000
else
    lock -e -f -c 000000
fi

# screen is locked: release the sleep delay lock so suspend can go ahead
if [[ -e /dev/fd/${XSS_SLEEP_LOCK_FD:--1} ]]; then
    exec {XSS_SLEEP_LOCK_FD}<&-
fi

# xss-lock treats the locker as running until it exits, and kills it to force an unlock
trap 'pkill -xu "$EUID" i3lock' TERM INT
while pgrep -xu "$EUID" i3lock >/dev/null; do
    sleep 0.5
done
