#!/bin/bash
# Author: Murray Buchanan
#
# clipster stores each copy as one history entry, which can itself contain
# embedded newlines (e.g. copying several lines of code/text at once). The
# previous version joined entries with clipster's default '\n' delimiter
# before piping straight into `rofi -dmenu`, which also splits rows on '\n'
# with no way to tell "newline between entries" apart from "newline inside
# one entry" - so a single multi-line clip showed up (and was selectable)
# as several separate, broken rofi rows.
#
# Fix: ask clipster for NUL-separated entries (-0) - NUL can't appear inside
# real clipboard text, so it's an unambiguous entry boundary - and split on
# that into a bash array, preserving each entry's internal newlines intact.
# Rofi still gets one row per real *entry* (not per line): any internal
# newlines are swapped for a "⏎" marker purely for display. The row picked
# in rofi is mapped back to its original, untouched array element via an
# index prefix, so what actually gets copied is the exact original text -
# newlines and all - not the flattened preview.
#
# Two more subtleties, found when a selected entry pasted as the wrong text:
#
# 1. clipster tracks PRIMARY and CLIPBOARD as two completely independent
#    histories. `clipster -o` with no board flag defaults to PRIMARY (every
#    mouse-drag text selection, an extremely noisy source) - the previous
#    version of this script never passed `-c`, so the picker was silently
#    listing PRIMARY history while everyone thinks of "clipboard" as
#    Ctrl+C/CLIPBOARD. Explicitly reading CLIPBOARD below.
#
# 2. clipster's daemon owns the CLIPBOARD/PRIMARY GTK selections itself and
#    watches for external ownership changes to record new history. Setting
#    the selection with an outside tool (`xclip -selection clipboard`) hands
#    ownership to that external process instead, which can race clipster's
#    own "reinstate last entry on empty selection" handler and get stomped
#    back to whatever was last really copied. Writing through `clipster -c`/
#    `-p` instead updates the daemon's own GTK clipboard object directly, no
#    external ownership handoff involved. Both boards are written so the
#    paste keybinding gets the right text regardless of which one it reads
#    from (Shift+Insert conventionally pastes PRIMARY in many X11 apps).

mapfile -d '' -t entries < <(clipster -c -o -n 20 -0)

MENU=""
for i in "${!entries[@]}"; do
    preview="${entries[$i]//$'\n'/ ⏎ }"
    MENU+="[$i] $preview"$'\n'
done

CHOICE=$(printf '%s' "${MENU%$'\n'}" | rofi -dmenu -p "📋 Clipboard" -i -location 0 -theme-str 'window {width: 600px; x-offset: 0; y-offset: 0; location: center;}')

if [ -n "$CHOICE" ]; then
    if [[ "$CHOICE" =~ ^\[([0-9]+)\] ]] && [ -n "${entries[${BASH_REMATCH[1]}]+_}" ]; then
        TEXT="${entries[${BASH_REMATCH[1]}]}"
    else
        # Fell through to a custom/unmatched rofi entry - use it verbatim.
        TEXT="$CHOICE"
    fi
    printf '%s' "$TEXT" | clipster -c
    printf '%s' "$TEXT" | clipster -p
    xdotool key --clearmodifiers shift+Insert
fi
