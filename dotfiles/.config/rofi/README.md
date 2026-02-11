# Rofi Configuration

This rofi configuration is based on [miketvo's dotfiles](https://github.com/miketvo/dotfiles/tree/main/archlinux-wsl/.config/rofi) with the Kanagawa Dragon color theme.

## Features

- **Kanagawa Dragon Theme**: Dark theme with warm colors and subtle transparency
- **Multiple Launch Modes**: Application launcher, window switcher, run command
- **Custom Scripts**: Desktop keybinds viewer
- **Icon Support**: Uses Papirus-Dark icon theme
- **JetBrains Mono Nerd Font**: Configured for optimal display

## Files

- `config.rasi` - Main configuration with Kanagawa Dragon theme
- `launch-drun.sh` - Application launcher (dmenu replacement)
- `launch-run.sh` - Command runner
- `launch-window.sh` - Window switcher
- `launch-desktop_keybinds.sh` - Desktop keybinds help viewer
- `scripts/desktop_keybinds.sh` - Helper script for keybinds display

## Usage

### Command Line

```bash
# Application launcher
rofi -show drun

# Or use the launcher script
~/.config/rofi/launch-drun.sh

# Window switcher
~/.config/rofi/launch-window.sh

# Run command
~/.config/rofi/launch-run.sh

# Show keybinds (requires ~/.desktop_keybinds.txt)
~/.config/rofi/launch-desktop_keybinds.sh
```

### i3 Keybindings

Add these to your `~/.config/i3/config`:

```
# Rofi launchers
bindsym $mod+d exec --no-startup-id ~/.config/rofi/launch-drun.sh
bindsym $mod+Shift+d exec --no-startup-id ~/.config/rofi/launch-run.sh
bindsym $mod+Tab exec --no-startup-id ~/.config/rofi/launch-window.sh
bindsym $mod+F1 exec --no-startup-id ~/.config/rofi/launch-desktop_keybinds.sh
```

## Color Scheme

The Kanagawa Dragon theme uses the following colors:

- **Background**: `#181616` (dark charcoal with transparency)
- **Foreground**: `#c5c9c5` (light grey)
- **Highlight**: `#e6c384` (warm yellow)
- **Selected**: `#323131` (dark grey)
- **Urgent**: `#c4746e` (muted red)

## Dependencies

- `rofi` - Application launcher
- `papirus-icon-theme` - Icon theme (optional but recommended)
- `JetBrains Mono Nerd Font` - Font with icon support (optional)

Install on Arch-based systems:
```bash
sudo pacman -S rofi papirus-icon-theme
yay -S ttf-jetbrains-mono-nerd
```

## Customization

### Change Font

Edit `config.rasi` and modify:
```
font: "Your Font Name 12";
```

### Change Theme Colors

All colors are defined at the top of `config.rasi` in the `* { ... }` section:
```
foreground: #c5c9c5ee;
background: #181616ee;
```

The `ee` at the end is the alpha (transparency) value in hex (238/255 ≈ 93% opacity).

### Change Number of Columns

In the `listview` section:
```
columns: 3;  // Change to 2, 4, 5, etc.
```

## Troubleshooting

### Icons Not Showing

Install Papirus icon theme:
```bash
sudo pacman -S papirus-icon-theme
```

### Font Issues

The configuration uses JetBrains Mono Nerd Font. If not installed, rofi will fall back to your default monospace font. Install with:
```bash
yay -S ttf-jetbrains-mono-nerd
```

### Transparency Not Working

Make sure you have a compositor running (like picom):
```bash
picom &
```

Add to your i3 config:
```
exec_always --no-startup-id picom -b
```

## Notes

- The keybinds viewer (`launch-desktop_keybinds.sh`) requires a `~/.desktop_keybinds.txt` file
- All launcher scripts use `exec` which means they replace the shell process (more efficient)
- Sidebar mode allows quick switching between different rofi modes
- The configuration includes extensive commented-out options for reference
