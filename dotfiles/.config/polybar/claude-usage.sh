#!/bin/bash
# Author: Murray Buchanan
#
# Claude subscription usage for polybar: 5-hour window %, when it resets
# (local time) and the 7-day %. Prints nothing (hiding the module) unless a
# Claude Code agent is running. Reads the OAuth token Claude Code keeps in
# ~/.claude/.credentials.json and asks the same endpoint /usage uses; Claude
# Code refreshes that token while it runs, so it is fresh whenever we show.

pgrep -x claude >/dev/null || exit 0

creds="$HOME/.claude/.credentials.json"
[[ -r $creds ]] || exit 0

# Last good reading, shown greyed out if a request fails so the bar doesn't flicker.
cache="${XDG_RUNTIME_DIR:-/tmp}/polybar-claude-usage"

token=$(jq -r '.claudeAiOauth.accessToken // empty' "$creds")
[[ -n $token ]] || exit 0

# Header goes in on stdin so the token never shows up in `ps`.
json=$(printf 'Authorization: Bearer %s\n' "$token" \
    | curl -sf -m 8 -H @- -H "anthropic-beta: oauth-2025-04-20" \
        https://api.anthropic.com/api/oauth/usage)

# Polybar markup: T3 = Hack Nerd Font (icons and gauge line).
dim='#8dabc8'

# Theme colour for a utilisation %: green, then orange from 60, red from 85.
level_colour() {
    if (( $1 >= 85 )); then echo '#d0503c'
    elif (( $1 >= 60 )); then echo '#bd7023'
    else echo '#6fae68'; fi
}

# "5h ━━━━━━━━ 27%": a line filled in the level colour over a dark track.
gauge() {
    local label=$1 pct=$2 colour filled i done='' rest=''
    colour=$(level_colour "$pct")
    filled=$(( (pct * 8 + 50) / 100 ))
    (( filled > 8 )) && filled=8
    for (( i = 0; i < 8; i++ )); do
        (( i < filled )) && done+='━' || rest+='━'
    done
    printf '%%{F%s}%s%%{F-} %%{T3}%%{F%s}%s%%{F#2e3d33}%s%%{F-}%%{T-} %%{F%s}%s%%%%{F-}' \
        "$dim" "$label" "$colour" "$done" "$rest" "$colour" "$pct"
}

render() {
    local five=$1 reset=$2 week=$3
    printf '%%{T3}%%{F#d97757}󰚩%%{F-}%%{T-}   %s %%{F%s}%%{T3}󰦖%%{T-}  %s%%{F-}' \
        "$(gauge 5h "$five")" "$dim" "$reset"
    [[ -n $week ]] && printf '  %%{F%s}│%%{F-}  %s' "$dim" "$(gauge 7d "$week")"
    echo
}

# Fields: 5h %, 5h reset (local HH:MM), 7d % (may be empty).
fields=$(jq -r '
    def at: sub("\\.[0-9]+.*$"; "Z") | fromdateiso8601 | strflocaltime("%H:%M");
    select(.five_hour)
    | [(.five_hour.utilization // 0 | floor),
       (.five_hour.resets_at | at),
       (.seven_day.utilization // "" | if . == "" then . else floor end)]
    | @tsv
' <<<"$json" 2>/dev/null)

if [[ -n $fields ]]; then
    printf '%s\n' "$fields" > "$cache"
    IFS=$'\t' read -r five reset week <<<"$fields"
    render "$five" "$reset" "$week"
elif [[ -r $cache ]]; then
    # Stale reading: show it greyed out.
    IFS=$'\t' read -r five reset week < "$cache"
    render "$five" "$reset" "$week" | sed -E 's/%\{F#[0-9a-f]{6}\}/%{F#5a6a78}/g'
fi
