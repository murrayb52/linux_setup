# Polybar Theme Options Guide

This directory contains 4 different polybar themes, all consolidated in a single directory structure.

## Directory Structure

All config files and scripts are now in the main polybar directory:
- `config_Option1`, `config_Option2`, `config_Option3`, `config_Option4` - Theme configurations
- `launch.sh` - Main launch script supporting all themes
- `switch-theme.sh` - Interactive theme switcher
- `*.sh` - Consolidated helper scripts used by various themes

## Available Themes

### Option1
- **Style**: Classic horizontal bar
- **Modules**: Tidal player controls, workspaces, system info
- **Bars**: Single top bar
- **Color Scheme**: Dark theme with blue accents

### Option2
- **Style**: Minimal design
- **Modules**: Essential system information
- **Bars**: Single top bar
- **Color Scheme**: Minimal dark theme

### Option3
- **Style**: Nordic-inspired design
- **Modules**: Full system monitoring
- **Bars**: Dual bars (top and bottom)
- **Color Scheme**: Nordic palette (blues and grays)

### Option4 (Default)
- **Style**: Comprehensive dual-bar layout
- **Modules**: Complete system monitoring, Tidal integration, power menu
- **Bars**: Top (time, workspaces, media) and Bottom (system stats, volume, power)
- **Color Scheme**: Green accents on dark background
- **Scripts**: Includes tidal.sh, playpause.sh, pub-ipv4.sh

## Switching Themes

### Method 1: Interactive Switcher (Easiest)
```bash
~/.config/polybar/switch-theme.sh
```

### Method 2: Environment Variable (Recommended for Permanent)
```bash
# Temporary (current session only)
export POLYBAR_OPTION="Option3"

# Permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export POLYBAR_OPTION="Option5"' >> ~/.bashrc
source ~/.bashrc
```

### Method 3: Edit launch.sh
Edit line 13 in `launch.sh`:
```bash
POLYBAR_OPTION="${POLYBAR_OPTION:-Option5}"
```

## Consolidated Scripts

All helper scripts are now in the main polybar directory:

- `playpause.sh` - Dynamic play/pause icon (used by Option4)
- `pub-ipv4.sh` - Show public IPv4 address (used by Option3, Option4)
- `player-mpris-simple.sh` - Media player integration (used by Option3)

## Module Overview

### Common Modules (all themes)
- **i3**: Workspace indicators
- **time/date**: Clock display

### Option4 Specific
- **Top Bar**: Time, workspaces, Tidal player
- **Bottom Bar**: CPU, memory, temperature, disk, network, volume, redshift, power menu

## Customization

To customize a theme:

1. Navigate to the polybar directory:
   ```bash
   cd ~/.config/polybar
   ```

2. Edit the desired config file:
   ```bash
   nano config_Option4
   ```

3. Reload polybar:
   ```bash
   ~/.config/polybar/launch.sh
   ```
   Or reload i3: `$mod+Shift+r`

## Troubleshooting

### Polybar doesn't start
- Check if launch.sh is executable: `chmod +x ~/.config/polybar/launch.sh`
- Check logs: `journalctl --user -u polybar -f`

### Modules not displaying
- Verify required dependencies are installed (see packages.txt)
- Check script permissions: `chmod +x ~/.config/polybar/*.sh`
- Ensure scripts are executable in the main polybar directory

### Theme not switching
- Verify POLYBAR_OPTION is set: `echo $POLYBAR_OPTION`
- Check that config_OptionX file exists
- Reload i3 after changing the variable

## Creating Your Own Theme

1. Copy an existing config:
   ```bash
   cd ~/.config/polybar
   cp config_Option4 config_MyCustomTheme
   ```

2. Edit the config file:
   ```bash
   nano config_MyCustomTheme
   ```

3. Set it as active:
   ```bash
   export POLYBAR_OPTION="MyCustomTheme"
   ```

## Dependencies

Required for all themes:
- `polybar`
- `Font Awesome` (for icons)
- `Hack` font

Additional for media modules:
- `playerctl` - Media player control
- `tidal-hifi` - Tidal desktop client

Additional for system modules:
- `wireless_tools` - Network info
- `sysstat` - System statistics

---

**Current Default**: Option4  
**Recommended for beginners**: Option4 (most features)  
**Recommended for minimal setup**: Option2
