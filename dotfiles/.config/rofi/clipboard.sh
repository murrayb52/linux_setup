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

mapfile -d '' -t entries < <(clipster -o -n 20 -0)

MENU=""
for i in "${!entries[@]}"; do
    preview="${entries[$i]//$'\n'/ ⏎ }"
    MENU+="[$i] $preview"$'\n'
done

CHOICE=$(printf '%s' "${MENU%$'\n'}" | rofi -dmenu -p "📋 Clipboard" -i -location 0 -theme-str 'window {width: 600px; x-offset: 0; y-offset: 0; location: center;}')

if [ -n "$CHOICE" ]; then
    if [[ "$CHOICE" =~ ^\[([0-9]+)\] ]] && [ -n "${entries[${BASH_REMATCH[1]}]+_}" ]; then
        printf '%s' "${entries[${BASH_REMATCH[1]}]}" | xclip -selection clipboard
    else
        # Fell through to a custom/unmatched rofi entry - use it verbatim.
        printf '%s' "$CHOICE" | xclip -selection clipboard
    fi
    xdotool key --clearmodifiers shift+Insert
fi
