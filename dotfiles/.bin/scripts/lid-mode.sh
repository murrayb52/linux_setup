#!/bin/bash
# Author: Murray Buchanan
#
# Toggles whether closing the laptop lid suspends the system, or does
# nothing at all. Backs the "lid" polybar module (config_Option5,
# [module/lid]) as a two-way rocker switch: exactly one of "sleep" / "awake"
# is ever active, never both, never neither.
#
# Mechanism: systemd-logind's HandleLidSwitch=suspend (the distro default,
# see /etc/systemd/logind.conf) only fires if the sleep targets are
# unmasked. Masking sleep.target and friends makes lid-close, `systemctl
# suspend`, and any ACPI lid event a no-op system-wide - no changes to
# logind.conf needed, and it's trivially reversible by unmasking again.
#
# Requires passwordless sudo for exactly these two invocations (see
# /etc/sudoers.d/lid-mode) so the polybar click doesn't hang waiting for a
# password prompt with no terminal attached.
#
# Usage:
#   lid-mode.sh sleep    # default systemd behaviour: lid close suspends
#   lid-mode.sh awake    # lid close does nothing
#   lid-mode.sh status   # print "sleep" or "awake" to stdout

set -euo pipefail

TARGETS=(sleep.target suspend.target hibernate.target hybrid-sleep.target)

usage() {
    echo "Usage: $(basename "$0") {sleep|awake|status}" >&2
    exit 1
}

current_state() {
    # `systemctl is-enabled` exits non-zero for a masked unit, which combined
    # with pipefail would make `| grep -q masked` report the wrong result -
    # capture the text instead of piping it.
    local state
    state=$(systemctl is-enabled "${TARGETS[0]}" 2>/dev/null || true)
    if [[ "$state" == "masked" ]]; then
        echo awake
    else
        echo sleep
    fi
}

case "${1:-}" in
    sleep)
        sudo /usr/bin/systemctl unmask "${TARGETS[@]}"
        notify-send "Lid switch" "Closing the lid will now suspend the system." 2>/dev/null || true
        ;;
    awake)
        sudo /usr/bin/systemctl mask "${TARGETS[@]}"
        notify-send "Lid switch" "Closing the lid will no longer suspend the system." 2>/dev/null || true
        ;;
    status)
        current_state
        ;;
    *)
        usage
        ;;
esac
