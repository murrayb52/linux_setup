#!/bin/bash
# Author: Murray Buchanan
#
# WiFi icon click handler for polybar. Previously opened a hand-rolled
# rofi network menu; now opens nmtui (NetworkManager's own TUI) instead,
# which already covers scan/connect/forget more completely. Runs in a
# floating, uniquely-classed terminal window - the i3 for_window rule
# (dotfiles/.config/i3/config) matches --class=floating-nmtui to float +
# centre this specific window without affecting any other terminal.

gnome-terminal --class=floating-nmtui --geometry=100x30 -- nmtui &
