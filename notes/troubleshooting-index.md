# Troubleshooting Index

Quick reference for common issues encountered during i3-gaps + Polybar setup.

## Critical Issues (Resolved)

### Status Bar / Taskbar Issues
- **[[issue-i3-taskbar-not-visible]]** - Main issue: taskbar not appearing
  - Overview of the problem and its impact
  - Links to specific sub-issues
  
### Polybar Configuration
- **[[issue-polybar-not-showing]]** - Polybar not launching on startup
  - Script permission issues
  - Environment variable requirements
  - Solution and automation

### Module-Specific Issues  
- **[[issue-ipv4-polybar-module]]** - IPv4 address display problems
  - Technical details about the fix
  - Robust IP detection method
  - Script explanation

## Main Documentation
- **[[setup_notes]]** - Comprehensive i3-gaps setup guide
  - Installation instructions
  - Common tweaks and fixes
  - Inspiration and resources

## Quick Fix Reference

| Problem | Quick Solution | Detailed Notes |
|---------|---------------|----------------|
| Polybar not showing | `chmod +x ~/.config/polybar/launch.sh` and set `POLYBAR_OPTION` | [[issue-polybar-not-showing]] |
| IPv4 not displaying | Script updated to use `ip -4 route get` | [[issue-ipv4-polybar-module]] |
| No taskbar at all | Check Polybar configuration | [[issue-i3-taskbar-not-visible]] |
| Script won't run | Check execute permissions with `chmod +x` | [[issue-polybar-not-showing]] |

## Automated Solutions
The `restore.sh` script now automatically handles:
- Setting execute permissions on all scripts
- Creating proper symlinks
- Displaying troubleshooting information

## Resources
- Main setup script: `../restore.sh`
- Configuration files: `../dotfiles/.config/`
- Change log: `../CHANGES.md`
