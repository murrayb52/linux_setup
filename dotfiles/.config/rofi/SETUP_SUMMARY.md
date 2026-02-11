# Rofi Setup Summary

Successfully added rofi configuration from miketvo's dotfiles to your linux-setup repository.

## What Was Added

### Configuration Files
```
dotfiles/.config/rofi/
├── config.rasi                      # Main config with Kanagawa Dragon theme
├── launch-drun.sh                   # Application launcher
├── launch-run.sh                    # Command runner
├── launch-window.sh                 # Window switcher
├── launch-desktop_keybinds.sh       # Keybinds viewer
├── README.md                        # Documentation
└── scripts/
    └── desktop_keybinds.sh          # Helper script for keybinds
```

### Features
- **Theme**: Kanagawa Dragon (dark charcoal background with warm colors)
- **Transparency**: 93% opacity for modern look
- **Icons**: Configured to use Papirus-Dark icon theme
- **Font**: JetBrains Mono Nerd Font
- **Modes**: Application launcher, window switcher, run command, keybinds viewer

## Installation

The rofi configuration is now:
1. ✅ Added to your dotfiles repository
2. ✅ Installed to `~/.config/rofi/` on your system
3. ✅ Included in `restore_config.sh` for future deployments
4. ✅ All launcher scripts are executable

## Quick Test

Try launching rofi:
```bash
rofi -show drun
```

Or use the launcher scripts:
```bash
~/.config/rofi/launch-drun.sh
```

## i3 Integration (Recommended)

Add these keybindings to your `~/.config/i3/config`:

```i3config
# Rofi application launcher (replaces dmenu)
bindsym $mod+d exec --no-startup-id ~/.config/rofi/launch-drun.sh

# Rofi run command
bindsym $mod+Shift+d exec --no-startup-id ~/.config/rofi/launch-run.sh

# Rofi window switcher
bindsym $mod+Tab exec --no-startup-id ~/.config/rofi/launch-window.sh

# Rofi keybinds help (optional, requires ~/.desktop_keybinds.txt)
bindsym $mod+F1 exec --no-startup-id ~/.config/rofi/launch-desktop_keybinds.sh
```

After adding these, reload i3:
```bash
i3-msg reload
# or press $mod+Shift+r
```

## Dependencies

Install these packages for full functionality:

```bash
# Required
sudo pacman -S rofi

# Recommended (for icons)
sudo pacman -S papirus-icon-theme

# Optional (for JetBrains Mono font)
yay -S ttf-jetbrains-mono-nerd
```

## Theme Preview

The Kanagawa Dragon theme uses:
- Dark charcoal background: #181616
- Light grey text: #c5c9c5
- Warm yellow highlights: #e6c384
- Green accents for selected items

## Customization

See [dotfiles/.config/rofi/README.md](README.md) for:
- Color customization
- Font changes
- Layout modifications
- Troubleshooting tips

## Next Steps

1. **Test the launcher**: Press `$mod+d` (if you added the i3 keybindings)
2. **Install optional dependencies**: Papirus icons and JetBrains Mono font
3. **Customize colors**: Edit `config.rasi` to match your preferred theme
4. **Create keybinds file**: Add a `~/.desktop_keybinds.txt` for the keybinds viewer

## Notes

- Rofi is now your application launcher (dmenu alternative)
- The configuration supports sidebar mode for quick mode switching
- Transparency requires a compositor (picom)
- The theme matches well with your existing Polybar/ZSH setup
