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

# Housekeeping (added so secrets can be got rid of, not just hidden):
#   - Alt+Shift+Delete wipes everything via clipboard-wipe.sh (memory, live
#     selection, the plaintext history file on disk and an fstrim), after a
#     "Yes, delete all" / "No" confirm
#   - Alt+Delete on a highlighted entry forgets just that one (from both
#     boards), after a Yes/No confirm, then the picker reopens so several can
#     be removed in a row
#
# Colours pulled from the bottom polybar's [color] section (config.ini)
# so this popup matches the bar it's launched from: overall background/text
# match the bar itself, and the selected row uses the same green
# (strong-highlight) the bar shows behind the lid/power icon once its menu
# is open (label-close-background). The base config.rasi's
# #element.normal.normal etc. rules are written in terms of @normal-background/
# @normal-foreground/... variables from its own top-level `* {}` block, not
# literal colours - so overriding those variables (rather than re-declaring
# the element selectors directly, which the cascade ignored) is what
# actually reaches the rendered rows.
ROFI_THEME='
* {
    background:                  #bb010101;
    foreground:                  #adc0b0;
    normal-background:           #bb010101;
    normal-foreground:           #adc0b0;
    alternate-normal-background: #bb010101;
    alternate-normal-foreground: #adc0b0;
    selected-normal-background:  #255426;
    selected-normal-foreground:  #adc0b0;
}
window {
    width: 600px;
    x-offset: 0;
    y-offset: 0;
    location: center;
    background-color: #bb010101;
    border: 2px;
    border-color: #548550;
    border-radius: 10px;
}
element {
    border-radius: 6px;
    padding: 6px;
}
inputbar {
    background-color: transparent;
    text-color: #adc0b0;
}
prompt {
    text-color: #adc0b0;
}
entry {
    text-color: #adc0b0;
    placeholder-color: #8dabc8;
}
'

# confirm "question" "yes label" - rofi Yes/No (defaults to No); succeeds only
# on the yes label.
confirm() {
    local answer
    answer=$(printf 'No\n%s\n' "$2" | rofi -dmenu -p "$1" -i -no-custom -theme-str "$ROFI_THEME")
    [ "$answer" = "$2" ]
}

while true; do
    mapfile -d '' -t entries < <(clipster -c -o -n 20 -0)

    MENU=""
    for i in "${!entries[@]}"; do
        preview="${entries[$i]//$'\n'/ ⏎ }"
        MENU+="[$i] $preview"$'\n'
    done

    CHOICE=$(printf '%s' "${MENU%$'\n'}" | rofi -dmenu -p "📋 Clipboard" -i -location 0 \
        -kb-custom-1 "Alt+Delete" \
        -kb-custom-2 "Alt+Shift+Delete" \
        -mesg "Enter: paste    Alt+Delete: forget entry    Alt+Shift+Delete: delete all" \
        -theme-str "$ROFI_THEME")
    STATUS=$?

    if [ "$STATUS" -eq 11 ]; then
        # Alt+Shift+Delete acts on the whole history, so it doesn't need a
        # highlighted row.
        confirm "Delete ALL clipboard history?" "Yes, delete all" && "$(dirname "$0")/clipboard-wipe.sh"
        exit 0
    fi

    [ -z "$CHOICE" ] && exit 0

    if [[ "$CHOICE" =~ ^\[([0-9]+)\] ]] && [ -n "${entries[${BASH_REMATCH[1]}]+_}" ]; then
        TEXT="${entries[${BASH_REMATCH[1]}]}"
    else
        # Fell through to a custom/unmatched rofi entry - use it verbatim.
        TEXT="$CHOICE"
    fi

    if [ "$STATUS" -eq 10 ]; then
        # Alt+Delete: forget this entry from both boards, plus the live
        # clipboard if it's what is currently sitting there.
        if confirm "Forget this entry?" "Yes"; then
            clipster -c --delete="$TEXT"
            clipster -p --delete="$TEXT"
            [ "$(xsel -b -o)" = "$TEXT" ] && xsel -b -c
            [ "$(xsel -p -o)" = "$TEXT" ] && xsel -p -c
        fi
        continue
    fi

    printf '%s' "$TEXT" | clipster -c
    printf '%s' "$TEXT" | clipster -p
    xdotool key --clearmodifiers shift+Insert
    exit 0
done
