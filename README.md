# Linux Setup Configuration

A comprehensive dotfiles and configuration management repository for a customized Linux desktop environment using i3wm, polybar, and rofi.

## 📁 Repository Structure

```
linux_setup/
├── dotfiles/              # All configuration files
│   ├── .config/
│   │   ├── i3/           # i3 window manager configuration
│   │   ├── polybar/      # Polybar status bar configurations
│   │   │   ├── Option1/          # Polybar theme option 1
│   │   │   ├── Option2/          # Polybar theme option 2
│   │   │   ├── Option3 - Nordic/ # Nordic theme
│   │   │   ├── Option4-Green/    # Green theme (default)
│   │   │   └── launch.sh         # Main polybar launcher
│   │   └── rofi/         # Rofi application launcher configuration
│   └── .bin/
│       └── scripts/      # Custom utility scripts
├── fonts/                # Custom fonts
├── Wallpapers/          # Desktop wallpapers
├── notes/               # Setup notes and documentation
├── packages.txt         # List of required packages
├── restore.sh          # Configuration restoration script
└── README.md           # This file
```

## 🚀 Quick Start

### Fresh Installation

1. **Clone this repository:**
   ```bash
   git clone <repository-url> ~/linux-setup
   cd ~/linux-setup/linux_setup
   ```

2. **Install required packages:**
   ```bash
   sudo apt update
   sudo apt install $(cat packages.txt)
   ```

3. **Run the restore script:**
   ```bash
   ./restore.sh
   ```

4. **Select your preferred polybar theme** (optional):
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   export POLYBAR_OPTION="Option4-Green"  # or Option1, Option2, Option3 - Nordic
   ```

5. **Reload i3:**
   - Press `$mod+Shift+r` (default: `Super+Shift+r`)

## 🎨 Polybar Themes

This setup includes 4 different polybar themes. Change themes by setting the `POLYBAR_OPTION` environment variable:

- **Option1**: Classic layout with Tidal integration
- **Option2**: Alternative minimal design
- **Option3 - Nordic**: Nordic color scheme
- **Option4-Green**: Green-themed (default) with dual bars

### Changing Themes

```bash
# Temporary (current session)
export POLYBAR_OPTION="Option3 - Nordic"
$mod+Shift+r  # Reload i3

# Permanent
echo 'export POLYBAR_OPTION="Option4-Green"' >> ~/.bashrc
source ~/.bashrc
```

## 🎵 Music Player Integration

This configuration is set up for **Tidal** (via tidal-hifi) with playerctl integration. All music controls work with Tidal:

- **Media Keys**: Play/pause, next, previous track
- **Mouse Buttons**: Side buttons for playback control
- **Polybar Modules**: Display current track and playback status

### Installing Tidal

```bash
# Install tidal-hifi from GitHub
# Visit: https://github.com/Mastermindzh/tidal-hifi/releases
```

## ⌨️ Key Bindings

### Window Management
- `$mod+Return` - Open terminal
- `$mod+Shift+q` - Close window
- `$mod+d` - Launch rofi application launcher
- `$mod+f` - Fullscreen toggle
- `$mod+h/v` - Split horizontal/vertical
- `$mod+1-0` - Switch to workspace 1-10

### System
- `$mod+Shift+Escape` - Lock screen
- `$mod+Shift+r` - Reload i3
- `$mod+Shift+e` - Exit i3

### Media Controls
- `XF86AudioPlay/Pause` - Play/pause
- `XF86AudioNext/Prev` - Next/previous track
- `XF86AudioRaiseVolume/LowerVolume` - Volume up/down
- `XF86MonBrightnessUp/Down` - Brightness control

### Application Shortcuts
- `$mod+n` - Open file manager (Nautilus)
- `$mod+c` - Open calculator (SpeedCrunch)
- `$mod+p` - Open PyCharm

## 📦 Required Packages

Essential packages (install via `packages.txt`):
- i3-wm / i3-gaps
- polybar
- rofi
- compton/picom (compositor)
- feh (wallpaper)
- playerctl (media control)
- Font Awesome (icons)
- Hack font

## 🔧 Configuration Files

### i3 Config
Location: `~/.config/i3/config`
- Window manager settings
- Key bindings
- Workspace configuration
- Application assignments

### Polybar Config
Location: `~/.config/polybar/[Option]/config`
- Status bar modules
- Colors and themes
- System monitoring
- Media player integration

### Rofi Config
Location: `~/.config/rofi/config.rasi`
- Application launcher styling
- Color scheme
- Layout configuration

## 🛠️ Custom Scripts

Located in `~/.bin/scripts/`:
- `screen_settings.sh` - Display configuration
- `brightnessUp.sh` / `brightnessDown.sh` - Brightness control
- `lockpixelate.sh` / `lockpretty.sh` - Screen lock effects

Polybar scripts (per theme):
- `tidal.sh` - Display current track
- `playpause.sh` - Play/pause icon
- `pub-ipv4.sh` - Public IP display

## 📝 Workspace Layout

1. **Firefox** 🦊
2. **Terminal** >_
3. **Code** 
4. **Files** 
5-9. **General** 
10. **Tidal** 

## 🎨 Color Scheme (Option4-Green)

- **Highlight**: `#aa102010`
- **Strong Highlight**: `#255426`
- **Background**: `#bb010101`
- **Text**: `#adc0b0`
- **Accent**: `#548550`

## 🔄 Updating Configurations

After making changes to configurations in this repository:

1. **If using symlinks** (recommended after running restore.sh):
   - Changes are automatically reflected
   - Just reload i3: `$mod+Shift+r`

2. **If not using symlinks**:
   - Re-run `./restore.sh` to update

## 📚 Additional Resources

- [i3 User Guide](https://i3wm.org/docs/userguide.html)
- [Polybar Wiki](https://github.com/polybar/polybar/wiki)
- [Rofi Documentation](https://github.com/davatorium/rofi)

## 👤 Author

Murray Buchanan

## 📄 License

Personal configuration files - use and modify as needed.

---

**Note**: Check `notes/setup_notes.md` for additional setup instructions and troubleshooting tips.
