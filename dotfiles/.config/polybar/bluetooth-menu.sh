#!/bin/bash
# Author: Murray Buchanan
#
# Bluetooth icon click handler for polybar. Previously opened a hand-rolled
# rofi bluetoothctl menu; now opens blueman-manager (the standard GTK
# Bluetooth manager, already installed) instead - full device pairing/
# trust/connect UI rather than a custom menu. Floats as its own window -
# the i3 for_window rule (dotfiles/.config/i3/config) matches its default
# WM_CLASS ("Blueman-manager") to float + centre it.

blueman-manager &
