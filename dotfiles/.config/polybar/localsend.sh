#!/bin/bash
# Author: Murray Buchanan
#
# LocalSend icon click handler for polybar. Opens LocalSend as a floating window.
# The i3 for_window rule (dotfiles/.config/i3/config) matches the app's
# WM_CLASS "Localsend_app" to float + centre it.

/usr/bin/localsend_app &
