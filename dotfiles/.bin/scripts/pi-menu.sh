#!/bin/bash
# Select a working folder before launching Pi. General is not security isolation.
set -u

# Include the managed Pi installer and common user-local npm executables.
export PATH="$PATH:$HOME/.pi/agent/bin:$HOME/.local/bin"

if ! command -v whiptail >/dev/null 2>&1; then
    printf 'Pi menu requires whiptail. Install it with: sudo apt install whiptail\n' >&2
    if [[ -t 0 ]]; then
        read -r -p 'Press Enter to close.'
    fi
    exit 1
fi

fail() {
    whiptail --title "Pi launcher" --msgbox "$1" 12 78
    exit 1
}

# Capture the selection (stderr), but keep the menu screen (stdout) on the TTY.
choice=$(whiptail --title "Pi — choose a workspace" \
    --menu "Select a folder to launch Pi (arrow keys, then Enter):" 16 78 3 \
    "General" "~/claude-sandbox" \
    "WellRead" "~/projects/WellRead Project/wellread" \
    "StudySmarter" "~/projects/StudySmarter/StudySmarterSite" 3>&1 1>&2 2>&3)
status=$?
case "$status" in
    0) ;;
    1|255) exit 0 ;; # Cancel / Escape: close without launching anything.
    *) exit "$status" ;;
esac

command -v pi >/dev/null 2>&1 || fail "Pi was not found. Install Pi and ensure its executable is on PATH."

case "$choice" in
    General)
        directory="$HOME/claude-sandbox"
        mkdir -p "$directory" || fail "Could not create sandbox folder: $directory"
        ;;
    WellRead) directory="$HOME/projects/WellRead Project/wellread" ;;
    StudySmarter) directory="$HOME/projects/StudySmarter/StudySmarterSite" ;;
    *) fail "Unknown workspace: $choice" ;;
esac

[[ -d "$directory" ]] || fail "Project folder does not exist: $directory"
cd -- "$directory" || fail "Could not open folder: $directory"

pi
# Preserve the old launcher's behaviour: leave a shell in the chosen folder.
exec zsh
