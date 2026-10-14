#!/bin/bash
# Author: Murray Buchanan
#
# The current i3 binding mode (e.g. "resize") for polybar, blinking between a
# solid orange block and orange text every half-second, the same rhythm as
# flockr's urgent workspaces. Prints an empty line (hiding the module) in the
# default mode.
#
# Runs as a polybar tail script: follows i3's mode events, and resubscribes if
# i3 restarts (which ends the subscription).

colour='#bd7023'
text='#0d0d0d'

# i3's current mode; "default" if i3 can't be reached.
current_mode() {
    local m
    m=$(i3-msg -t get_binding_state 2>/dev/null | jq -r '.name // empty' 2>/dev/null)
    echo "${m:-default}"
}

mode=$(current_mode)
on=1

while true; do
    coproc events { exec i3-msg -t subscribe -m '[ "mode" ]'; }
    while true; do
        if [[ $mode == default ]]; then
            echo
            read -r line <&"${events[0]}" || break
        else
            if (( on )); then
                echo "%{B$colour}%{F$text} $mode %{F-}%{B-}"
            else
                echo "%{F$colour} $mode %{F-}"
            fi
            on=$(( !on ))
            read -r -t 0.5 line <&"${events[0]}"
            status=$?
            (( status > 128 )) && continue  # timed out: next blink
            (( status != 0 )) && break
        fi
        mode=$(jq -r '.change // "default"' <<<"$line")
        on=1
    done
    # The subscription ended (i3 restarting): wait for i3, then pick up its mode.
    kill "$events_PID" 2>/dev/null
    sleep 1
    mode=$(current_mode)
done
