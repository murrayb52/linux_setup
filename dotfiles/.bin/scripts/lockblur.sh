#!/bin/bash

# SCRIPT FOR [BLURRED] i3lock CONFIGURATION
# Locks over a blurred, dimmed screenshot with a frosted padlock badge in the middle
# (built by lockblur-bg.py). Falls back to a plain black lock if that fails.
# Run by xss-lock (--transfer-sleep-lock), so it also locks before suspend/lid close.
# DEPENDENCIES: i3lock, lockblur-bg.py

# the image is a screenshot, so keep it in the private, RAM-backed runtime dir
IMG=$(mktemp -p "${XDG_RUNTIME_DIR:-/tmp}" lockblur.XXXXXX)
trap 'rm -f "$IMG"' EXIT INT TERM

# i3lock forks once it holds the screen, so when this returns we're locked
lock() {
    if [[ -e /dev/fd/${XSS_SLEEP_LOCK_FD:--1} ]]; then
        # keep xss-lock's sleep delay lock out of the forked i3lock
        i3lock "$@" {XSS_SLEEP_LOCK_FD}<&-
    else
        i3lock "$@"
    fi
}

if raw=$("$(dirname "$0")/lockblur-bg.py" "$IMG"); then
    lock -e -f --raw="$raw" -i "$IMG" || lock -e -f -c 000000
else
    lock -e -f -c 000000
fi
# i3lock has read the image by the time it forks
rm -f "$IMG"

# screen is locked: release the sleep delay lock so suspend can go ahead
if [[ -e /dev/fd/${XSS_SLEEP_LOCK_FD:--1} ]]; then
    exec {XSS_SLEEP_LOCK_FD}<&-
fi

# xss-lock treats the locker as running until it exits, and kills it to force an unlock
trap 'pkill -xu "$EUID" i3lock' TERM INT
while pgrep -xu "$EUID" i3lock >/dev/null; do
    sleep 0.5
done
