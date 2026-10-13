#!/bin/bash
# Author: Murray Buchanan
#
# Claude subscription usage for polybar: one gauge, either the 5-hour window
# or the 7-day budget, with when it resets (local time). Clicking the module
# sends SIGUSR1, which swaps between the two. Prints an empty line (hiding
# the module) unless a Claude Code agent is running. Reads the OAuth token
# Claude Code keeps in ~/.claude/.credentials.json and asks the same endpoint
# /usage uses; Claude Code refreshes that token while it runs, so it is fresh
# whenever we show.
#
# Runs as a polybar tail script: loops forever, redrawing every few seconds
# (so it appears soon after an agent starts) and immediately on SIGUSR1.

creds="$HOME/.claude/.credentials.json"

# Last good reading, shown greyed out if a request fails so the bar doesn't flicker.
cache="${XDG_RUNTIME_DIR:-/tmp}/polybar-claude-usage"

# The endpoint rate-limits (429) when polled every minute, so ask at most once
# per max_age seconds, failures included. The stamp's mtime is when we last
# asked; its contents ("ok"/"fail") whether that worked.
stamp="$cache.asked"
max_age=300

# Which budget to show: 5h or 7d.
view=5h

# Polybar markup: T3 = Hack Nerd Font (icons and gauge line).
dim='#8dabc8'

# Theme colour for a utilisation %: green, then orange and red from per-budget
# thresholds (5h: 75/90, 7d: 60/85).
level_colour() {
    local label=$1 pct=$2 orange=60 red=85
    [[ $label == 5h ]] && orange=75 red=90
    if (( pct >= red )); then echo '#d0503c'
    elif (( pct >= orange )); then echo '#bd7023'
    else echo '#6fae68'; fi
}

# "5h ━━━━━━━━ 27%": a line filled in the level colour over a dark track.
gauge() {
    local label=$1 pct=$2 colour filled i done='' rest=''
    colour=$(level_colour "$label" "$pct")
    filled=$(( (pct * 8 + 50) / 100 ))
    (( filled > 8 )) && filled=8
    for (( i = 0; i < 8; i++ )); do
        (( i < filled )) && done+='━' || rest+='━'
    done
    printf '%%{F%s}%s%%{F-} %%{T3}%%{F%s}%s%%{F#2e3d33}%s%%{F-}%%{T-} %%{F%s}%s%%%%{F-}' \
        "$dim" "$label" "$colour" "$done" "$rest" "$colour" "$pct"
}

render() {
    local label=$1 pct=$2 reset=$3
    printf '%%{T3}%%{F#d97757}󰚩%%{F-}%%{T-}   %s %%{F%s}%%{T3}󰦖%%{T-}  %s%%{F-}\n' \
        "$(gauge "$label" "$pct")" "$dim" "$reset"
}

# Ask the endpoint (at most once per max_age) and update the cache; sets status.
refresh() {
    if [[ -r $stamp ]] && (( $(date +%s) - $(stat -c %Y "$stamp") < max_age )); then
        status=$(<"$stamp")
        return
    fi

    local token json fields
    token=$(jq -r '.claudeAiOauth.accessToken // empty' "$creds")
    [[ -n $token ]] || { status=fail; return; }

    # Header goes in on stdin so the token never shows up in `ps`.
    json=$(printf 'Authorization: Bearer %s\n' "$token" \
        | curl -sf -m 8 -H @- -H "anthropic-beta: oauth-2025-04-20" \
            https://api.anthropic.com/api/oauth/usage)

    # Fields: 5h %, 5h reset (HH:MM), 7d %, 7d reset (Day HH:MM); 7d may be empty.
    fields=$(jq -r '
        def at(f): sub("\\.[0-9]+.*$"; "Z") | fromdateiso8601 | strflocaltime(f);
        select(.five_hour)
        | [(.five_hour.utilization // 0 | floor),
           (.five_hour.resets_at | at("%H:%M")),
           (.seven_day.utilization // "" | if . == "" then . else floor end),
           (.seven_day.resets_at // "" | if . == "" then . else at("%a %H:%M") end)]
        | @tsv
    ' <<<"$json" 2>/dev/null)

    status=fail
    if [[ -n $fields ]]; then
        printf '%s\n' "$fields" > "$cache"
        status=ok
    fi
    echo "$status" > "$stamp"
}

draw() {
    pgrep -x claude >/dev/null && [[ -r $creds ]] || { echo; return; }
    refresh
    [[ -r $cache ]] || { echo; return; }

    local five five_reset week week_reset out
    IFS=$'\t' read -r five five_reset week week_reset < "$cache"
    if [[ $view == 7d && -n $week ]]; then
        out=$(render 7d "$week" "$week_reset")
    else
        out=$(render 5h "$five" "$five_reset")
    fi

    if [[ $status == ok ]]; then
        echo "$out"
    else
        # Stale reading: show it greyed out.
        sed -E 's/%\{F#[0-9a-f]{6}\}/%{F#5a6a78}/g' <<<"$out"
    fi
}

trap '[[ $view == 5h ]] && view=7d || view=5h' USR1

while :; do
    draw
    # Background sleep so SIGUSR1 interrupts the wait and redraws at once.
    sleep 5 &
    wait $!
    kill $! 2>/dev/null
done
