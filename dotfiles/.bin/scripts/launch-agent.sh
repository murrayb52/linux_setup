#!/bin/bash
# Select an agent harness (Claude Code or Pi) and a working folder on one
# screen, then launch it. General is not security isolation.
set -u

# Include the managed Pi installer and common user-local npm executables.
export PATH="$PATH:$HOME/.pi/agent/bin:$HOME/.local/bin"

# Put nvm's default Node on PATH without sourcing nvm.sh (which is slow), so
# this can run straight from a key binding rather than via `zsh -ic`.
if [[ -r "$HOME/.nvm/alias/default" ]]; then
    nvm_default=$(<"$HOME/.nvm/alias/default")
    nvm_bin=$(ls -d "$HOME/.nvm/versions/node/v${nvm_default#v}"*/bin 2>/dev/null | sort -V | tail -n 1)
    [[ -n "$nvm_bin" ]] && export PATH="$nvm_bin:$PATH"
fi

harness_names=("Claude Code" "Pi")
harness_cmds=("claude" "pi")

workspace_names=("General" "WellRead" "StudySmarter" "flockr" "linux-setup")
workspace_dirs=(
    "$HOME/claude-sandbox"
    "$HOME/projects/WellRead Project/wellread"
    "$HOME/projects/StudySmarter/StudySmarterSite"
    "$HOME/projects/flockr"
    "$HOME/projects/linux-setup"
)

# Permanent workspaces added from the menu, one "name<TAB>path" per line.
saved_workspaces="${XDG_CONFIG_HOME:-$HOME/.config}/launch-agent/workspaces"
if [[ -r $saved_workspaces ]]; then
    while IFS=$'\t' read -r name dir; do
        [[ -n $name && -n $dir ]] || continue
        workspace_names+=("$name")
        workspace_dirs+=("${dir/#\~/$HOME}")
    done < "$saved_workspaces"
fi

new_label="+ New"
workspace_names+=("$new_label")
workspace_dirs+=("temporary or permanent folder")

fail() {
    printf '\n  %s\n\n' "$1" >&2
    read -rsn1 -p '  Press any key to close.'
    exit 1
}

restore_screen() { printf '\e[?25h\e[?1049l'; }

draw() {
    local i marker style
    printf '\e[H\e[2J'
    printf '\n  \e[1mLaunch agent\e[0m\n\n'
    printf '  Harness:  \e[1;36m◀ %s ▶\e[0m   \e[2m(Tab to switch)\e[0m\n\n' "${harness_names[$harness]}"
    printf '  Workspace:\n'
    for i in "${!workspace_names[@]}"; do
        if (( i == row )); then marker='›'; style='\e[7m'; else marker=' '; style=''; fi
        (( i == count - 1 )) && printf '\n'
        printf "  %s ${style} %-14s\e[0m \e[2m%s\e[0m\n" "$marker" "${workspace_names[$i]}" "${workspace_dirs[$i]/#$HOME/\~}"
    done
    printf '\n  \e[2m↑/↓ workspace · Tab/Shift+Tab harness · Enter launch · Esc/q quit\e[0m'
}

harness=0
row=0
count=${#workspace_names[@]}

printf '\e[?1049h\e[?25l'
trap restore_screen EXIT

while true; do
    draw
    IFS= read -rsn1 key
    if [[ $key == $'\e' ]]; then
        # Arrow keys and Shift+Tab arrive as escape sequences; a lone Esc quits.
        IFS= read -rsn2 -t 0.05 rest || true
        key+=$rest
    fi
    case "$key" in
        $'\t') harness=$(( (harness + 1) % ${#harness_names[@]} )) ;;
        $'\e[Z') harness=$(( (harness - 1 + ${#harness_names[@]}) % ${#harness_names[@]} )) ;;
        $'\e[A'|k) row=$(( (row - 1 + count) % count )) ;;
        $'\e[B'|j) row=$(( (row + 1) % count )) ;;
        '') break ;; # Enter
        $'\e'|q) exit 0 ;;
    esac
done

restore_screen
trap - EXIT

# "New…": ask for a throwaway temp folder or a named folder that is saved to
# the menu for next time.
if (( row == count - 1 )); then
    printf '\n  \e[1mNew workspace\e[0m\n\n  [t] Temporary (deleted on reboot)\n  [p] Permanent (added to this menu)\n\n  Choice: '
    IFS= read -rsn1 kind
    printf '%s\n\n' "$kind"
    case "$kind" in
        t|T)
            dir=$(mktemp -d "${TMPDIR:-/tmp}/agent-XXXXXX") || fail "Could not create a temporary folder."
            workspace_names[$row]="Temporary"
            ;;
        p|P)
            read -rp '  Name: ' name
            [[ -n $name && $name != *$'\t'* ]] || fail "A name is required."
            read -re -i "~/projects/$name" -p '  Folder: ' dir
            dir=${dir/#\~/$HOME}
            [[ -n $dir ]] || fail "A folder is required."
            mkdir -p -- "$dir" || fail "Could not create folder: $dir"
            mkdir -p -- "${saved_workspaces%/*}" \
                && printf '%s\t%s\n' "$name" "${dir/#$HOME/\~}" >> "$saved_workspaces" \
                || fail "Could not save workspace to $saved_workspaces"
            workspace_names[$row]=$name
            ;;
        *) exit 0 ;;
    esac
    workspace_dirs[$row]=$dir
fi

agent=${harness_names[$harness]}
agent_cmd=${harness_cmds[$harness]}
directory=${workspace_dirs[$row]}

command -v "$agent_cmd" >/dev/null 2>&1 \
    || fail "$agent ($agent_cmd) was not found. Ensure its executable is on PATH."

if [[ ${workspace_names[$row]} == General ]]; then
    mkdir -p "$directory" || fail "Could not create sandbox folder: $directory"
fi

[[ -d "$directory" ]] || fail "Project folder does not exist: $directory"
cd -- "$directory" || fail "Could not open folder: $directory"

"$agent_cmd"
# Preserve the old launcher's behaviour: leave a shell in the chosen folder.
exec zsh
