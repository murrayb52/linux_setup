#!/bin/bash
# Author: Murray Buchanan
#
# Mail icon click handler for polybar. Opens Tuta Mail as a floating window.
# The i3 for_window rule (dotfiles/.config/i3/config) matches the app's
# WM_CLASS "tutanota-desktop" to float + centre it.

/home/muzz/.local/bin/tutanota-desktop-linux.AppImage &
