#!/bin/bash
# Author: Murray Buchanan
#
# Wipe clipboard history completely - not just from the rofi picker, but from
# memory, the live selections and disk. Run from clipboard.sh after a confirm.
#
# Why this isn't just `clipster --erase-entire-board`: that only empties one
# board (the default, PRIMARY) inside the running daemon, leaves CLIPBOARD
# alone, doesn't touch the live selection, and leaves the plaintext history
# file (~/.local/share/clipster/history) on disk until the next flush.
# Instead:
#
# 1. Stop the daemon via its pid file. It only handles SIGINT (which flushes
#    history to disk on exit); SIGTERM just ends it, so nothing more is written.
# 2. Clear both live selections. With the daemon gone nobody is reinstating
#    "the last entry" over the top of an empty clipboard.
# 3. shred the history file (and any tmp* left by an interrupted atomic write -
#    clipster writes history to a tmp file then renames it into place).
# 4. Start a fresh daemon with an empty history.
#
# 5. fstrim /. clipster rewrites history via tmp-file + rename, so earlier
#    saved versions were already freed (not overwritten) on disk, and shred
#    can't reach them on ext4/NVMe. TRIM discards those freed blocks. It needs
#    root, so it goes through pkexec (the polkit agent started in the i3
#    config shows the password prompt) and runs in the background so the
#    prompt/trim doesn't hold anything up. Skipped if the prompt is dismissed;
#    only full-disk encryption makes old copies truly unreadable.

DATA_DIR="${CLIPSTER_DATA_DIR:-$HOME/.local/share/clipster}"
PID_FILE="${CLIPSTER_PID_FILE:-/run/user/$(id -u)/clipster.pid}"

if [ -r "$PID_FILE" ]; then
    pid=$(<"$PID_FILE")
    kill "$pid" 2>/dev/null
    for _ in $(seq 50); do
        kill -0 "$pid" 2>/dev/null || break
        sleep 0.1
    done
    kill -9 "$pid" 2>/dev/null
fi

xsel -b -c
xsel -p -c

find "$DATA_DIR" -maxdepth 1 -type f \( -name history -o -name 'tmp*' \) \
    -exec shred -zu {} +

setsid -f clipster -d >/dev/null 2>&1

notify-send -u low -t 2500 "📋 Clipboard wiped" "History cleared from memory and disk"

if [ -z "$CLIPSTER_NO_TRIM" ]; then
    (
        if pkexec fstrim /; then
            notify-send -u low -t 2500 "📋 Disk trimmed" "Freed blocks discarded (fstrim /)"
        else
            notify-send -u normal "📋 fstrim skipped" "Old copies may remain in freed disk blocks"
        fi
    ) >/dev/null 2>&1 &
fi
