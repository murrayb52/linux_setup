# Troubleshooting Index

Quick reference for common issues encountered during i3-gaps + Polybar setup.

## Hardware-Specific Issues

### ASUS Vivobook S14
- **[[hardware-asus-vivobook-s14-wifi-suspend]]** — Wi-Fi dies permanently after lid close / suspend
  - Root cause: s2idle puts RTL8852BE into D3cold (PCIe fully powered off); device vanishes from bus
  - Fix: udev rule `ATTR{d3cold_allowed}="0"` on `0000:01:00.0` — keeps device on bus during s2idle
  - S3 deep sleep also fixes Wi-Fi but breaks WMI hotkeys (F4–F12) — do not use
  - Also covers: GRUB kernel pinning (6.14 won't boot, use 6.12 mainline)

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

### Lid Switch
- **[[polybar-lid-switch]]** — toggle lid-close sleep behaviour from the bar
  - Rocker-style popup next to the power button; `lid-mode.sh` masks/unmasks the sleep targets
  - Needs a sudoers rule at `/etc/sudoers.d/lid-mode` that a plain repo restore won't create

## Known Bugs (Not Yet Fixed)

- **[[dotfiles-symlinks-not-applied]]** — `restore_config.sh`'s `backup_if_exists` copies
  instead of moving the existing config, so `~/.config/polybar` and `~/.bin` are stuck as
  frozen copies, not symlinks into the repo. Editing files in `dotfiles/` silently doesn't
  reach the live system until this is fixed or the live dirs are manually re-symlinked.

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
