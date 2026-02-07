# Issue: i3 Status Bar Not Visible

## Problem
The i3 status bar was not visible, making it impossible to see workspace indicators, system status, or other bar information.

## Root Cause
The i3 configuration was set to launch Polybar as the status bar replacement, but Polybar wasn't starting due to:
1. Missing execute permissions on launch script
2. Missing theme environment variable

## Context
Modern i3 setups often replace the default i3bar with Polybar, which offers:
- More customization options
- Better aesthetics
- Modular configuration
- Custom scripts and modules

The i3 config includes:
```bash
exec_always --no-startup-id ~/.config/polybar/launch.sh
```

This tells i3 to launch Polybar instead of using the built-in i3bar.

## Solution
Fixed by resolving the Polybar startup issues - see [[issue-polybar-not-showing]] for full details:

1. Made polybar scripts executable
2. Set the POLYBAR_OPTION environment variable
3. Updated restore script to automate these steps

## Verification
After fixing, you should see:
- Polybar appearing at the top of the screen
- Workspace numbers/names
- System information (CPU, memory, network, etc.)
- Custom modules (IPv4 address, etc.)

## Alternative: Using Default i3bar
If you prefer the default i3 status bar instead of Polybar, comment out the Polybar launch line in `~/.config/i3/config`:

```bash
# exec_always --no-startup-id ~/.config/polybar/launch.sh
```

And add a bar configuration block:
```text
bar {
    status_command i3status
    position top
}
```

## Related Notes
- [[issue-polybar-not-showing]] - Polybar startup configuration
- [[issue-ipv4-polybar-module]] - IPv4 display issues
- [[setup_notes]] - Main setup documentation
