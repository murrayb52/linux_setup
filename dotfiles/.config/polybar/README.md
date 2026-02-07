# Polybar Theme Options Guide

This directory contains 4 different polybar themes. Each has its own unique style and module layout.

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

### Option3 - Nordic
- **Style**: Nordic-inspired design
- **Modules**: Full system monitoring
- **Bars**: Dual bars (top and bottom)
- **Color Scheme**: Nordic palette (blues and grays)

### Option4-Green (Default)
- **Style**: Comprehensive dual-bar layout
- **Modules**: Complete system monitoring, Tidal integration, power menu
- **Bars**: Top (time, workspaces, media) and Bottom (system stats, volume, power)
- **Color Scheme**: Green accents on dark background
- **Scripts**: Includes tidal.sh, playpause.sh, pub-ipv4.sh

## Switching Themes

### Method 1: Environment Variable (Recommended)
```bash
# Temporary (current session only)
export POLYBAR_OPTION="Option3 - Nordic"

# Permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export POLYBAR_OPTION="Option4-Green"' >> ~/.bashrc
source ~/.bashrc
```

### Method 2: Edit launch.sh
Edit line 13 in `launch.sh`:
```bash
POLYBAR_OPTION="${POLYBAR_OPTION:-Option4-Green}"
```

### Method 3: Direct Launch
```bash
# From the specific option directory
cd ~/.config/polybar/Option4-Green
./launch.sh
```

## Theme-Specific Scripts

### Option1
- `tidal.sh` - Display current Tidal track

### Option3 - Nordic
- `pub-ipv4.sh` - Show public IPv4 address
- `player-mpris-simple.sh` - Media player integration

### Option4-Green
- `tidal.sh` - Display current Tidal track with artist
- `playpause.sh` - Dynamic play/pause icon
- `pub-ipv4.sh` - Show public IPv4 address

## Module Overview

### Common Modules (all themes)
- **i3**: Workspace indicators
- **time/date**: Clock display

### Option4-Green Specific
- **Top Bar**: Time, workspaces, Tidal player
- **Bottom Bar**: CPU, memory, temperature, disk, network, volume, redshift, power menu

## Customization

To customize a theme:

1. Navigate to the theme directory:
   ```bash
   cd ~/.config/polybar/Option4-Green
   ```

2. Edit the config file:
   ```bash
   nano config
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
- Check script permissions in the theme directory
- Ensure scripts are executable: `chmod +x ~/.config/polybar/Option*/*.sh`

### Theme not switching
- Verify POLYBAR_OPTION is set: `echo $POLYBAR_OPTION`
- Check that the theme directory exists
- Reload i3 after changing the variable

## Creating Your Own Theme

1. Copy an existing theme:
   ```bash
   cd ~/.config/polybar
   cp -r Option4-Green MyCustomTheme
   ```

2. Edit the config file:
   ```bash
   nano MyCustomTheme/config
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

**Current Default**: Option4-Green  
**Recommended for beginners**: Option4-Green (most features)  
**Recommended for minimal setup**: Option2
