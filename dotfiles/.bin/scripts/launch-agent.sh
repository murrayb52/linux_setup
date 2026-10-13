#!/bin/bash
# Select an agent (Claude or Pi) and a working folder, then launch it.
# General is not security isolation.
set -u

# Include the managed Pi installer and common user-local npm executables.
export PATH="$PATH:$HOME/.pi/agent/bin:$HOME/.local/bin"

if ! command -v whiptail >/dev/null 2>&1; then
    printf 'This launcher requires whiptail. Install it with: sudo apt install whiptail\n' >&2
    if [[ -t 0 ]]; then
        read -r -p 'Press Enter to close.'
    fi
    exit 1
fi

fail() {
    whiptail --title "Agent launcher" --msgbox "$1" 12 78
    exit 1
}

# Capture the selection (stderr), but keep the menu screen (stdout) on the TTY.

# 1. Choose the agent. Claude is the default (pre-selected) row.
agent=$(whiptail --title "Launch agent — choose one" \
    --default-item "Claude" \
    --menu "Select an agent (arrow keys, then Enter):" 15 78 2 \
    "Claude" "Anthropic Claude Code" \
    "Pi" "Pi agent" 3>&1 1>&2 2>&3)
status=$?
case "$status" in
    0) ;;
    1|255) exit 0 ;; # Cancel / Escape: close without launching anything.
    *) exit "$status" ;;
esac

# 2. Choose the workspace folder.
choice=$(whiptail --title "$agent — choose a workspace" \
    --menu "Select a folder to launch $agent (arrow keys, then Enter):" 17 78 4 \
    "General" "~/claude-sandbox" \
    "WellRead" "~/projects/WellRead Project/wellread" \
    "StudySmarter" "~/projects/StudySmarter/StudySmarterSite" \
    "flockr" "~/projects/flockr" 3>&1 1>&2 2>&3)
status=$?
case "$status" in
    0) ;;
    1|255) exit 0 ;; # Cancel / Escape: close without launching anything.
    *) exit "$status" ;;
esac

# Resolve the chosen agent to its command.
case "$agent" in
    Claude) agent_cmd="claude" ;;
    Pi)     agent_cmd="pi" ;;
    *)      fail "Unknown agent: $agent" ;;
esac
command -v "$agent_cmd" >/dev/null 2>&1 \
    || fail "$agent ($agent_cmd) was not found. Ensure its executable is on PATH."

case "$choice" in
    General)
        directory="$HOME/claude-sandbox"
        mkdir -p "$directory" || fail "Could not create sandbox folder: $directory"
        ;;
    WellRead) directory="$HOME/projects/WellRead Project/wellread" ;;
    StudySmarter) directory="$HOME/projects/StudySmarter/StudySmarterSite" ;;
    flockr) directory="$HOME/projects/flockr" ;;
    *) fail "Unknown workspace: $choice" ;;
esac

[[ -d "$directory" ]] || fail "Project folder does not exist: $directory"
cd -- "$directory" || fail "Could not open folder: $directory"

"$agent_cmd"
# Preserve the old launcher's behaviour: leave a shell in the chosen folder.
exec zsh
