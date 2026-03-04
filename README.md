# Linux Configuration Restore

A comprehensive dotfiles and configuration management repository for a customized Linux desktop environment using i3wm, polybar, and rofi.

## 📁 Repository Structure
- **dotfiles/**: [dotfiles/](dotfiles/) — all configuration (i3, polybar, rofi, .bin scripts).
- **Restore scripts**: [install.sh](install.sh), [dotfiles/restore_config.sh](dotfiles/restore_config.sh), [restore_terminal.sh](restore_terminal.sh) — installers and symlink deployers.
- **Packages**: [minimum_packages.txt](minimum_packages.txt) — minimal package list used by `install.sh`.
- **Fonts & Wallpapers**: [fonts/](fonts/) and [Wallpapers/](Wallpapers/).
- **Notes**: [notes/Setup/setup_obsidian.md](notes/Setup/setup_obsidian.md) and other setup notes.


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
├── minimum_packages.txt # Minimal packages list used by install.sh
├── install.sh     # Full configuration restoration script (one-time)
└── README.md           # This file
```

## 🚀 Quick Install
### 1. Clone this repository:

1. Clone repo with ssh key: (see [setup_notes/Quick Setup.md](setup_notes/Quick%20Setup.md) git ssh keys setup) 
```shell
mkdir ~/project
cd ~/projects
git clone git@github.com:murrayb52/linux_setup.git
```

### 2. Run install script
``` shell
cd ~/projects/linux_setup
chmod +x install.sh
./install.sh`
```

### How the install script works
- Installs:
   - required packages from `minimum_packages.txt`
   - required fonts (including MesloLGS used by Powerlevel10k)
   - wallpapers
- Configures the following configurations from `dotfiles/`(via [dotfiles/restore_config.sh](dotfiles/restore_config.sh)):
   - i3 config
   - polybar config
   - rofi config
- Configures ZSH terminal config (with [restore_terminal.sh](restore_terminal.sh))
- (Optional) Sets up Obsidian vault:
   - symlinks setup_notes to `~/ObsidianVault` for the minimum setup notes
   - installs and configures SyncThing to restore remaining Obsidian Vault (intentionally not tracked by a git repo) 


### 3. (if needed) Switch to i3
For Ubuntu:
1. Log out
2. Click the gear icon (bottom right)
3. Select *i3*
3. Log in

## Default Configuration
- **Window manager**: i3 (i3-gaps features enabled). Config located at [dotfiles/.config/i3/config](dotfiles/.config/i3/config).
- **Status bar**: Polybar with selectable themes. Default option is `Option5` (see [dotfiles/.config/polybar/launch.sh](dotfiles/.config/polybar/launch.sh)). For `Option5` the launcher starts `main` and `bottom` on the primary monitor and `external` bars on other connected monitors.
- **Launcher**: Rofi styling comes from [dotfiles/.config/rofi/config.rasi](dotfiles/.config/rofi/config.rasi).
- **Compositor & wallpaper**: Picom (compositor) and feh (wallpaper) are started from i3 config; screen settings come from `.bin/scripts/screen_settings.sh`.

**Customization**
- **Change polybar theme**: set `POLYBAR_OPTION` in your shell (e.g. add `export POLYBAR_OPTION="Option4"` to `~/.bashrc`) or edit [dotfiles/.config/polybar/launch.sh](dotfiles/.config/polybar/launch.sh).
- **Edit i3 behaviour**: modify [dotfiles/.config/i3/config](dotfiles/.config/i3/config) then reload i3 (`$mod+Shift+r`).
- **Edit rofi theme**: change [dotfiles/.config/rofi/config.rasi](dotfiles/.config/rofi/config.rasi).
- **Dotfiles deployment**: re-run `./install.sh` to apply package/font/wallpaper changes, or run [dotfiles/restore_config.sh](dotfiles/restore_config.sh) to (re)create symlinks for configuration files only.

### ⌨️ Key Bindings

Window Management
- `$mod+Return` - Open terminal
- `$mod+Shift+q` - Close window
- `$mod+d` - Launch rofi application launcher
- `$mod+f` - Fullscreen toggle
- `$mod+h/v` - Split horizontal/vertical
- `$mod+1-0` - Switch to workspace 1-10

System
- `$mod+Shift+Escape` - Lock screen
- `$mod+Shift+r` - Reload i3
- `$mod+Shift+e` - Exit i3

Media Controls (disabled by default)
- `XF86AudioPlay/Pause` - Play/pause
- `XF86AudioNext/Prev` - Next/previous track
- `XF86AudioRaiseVolume/LowerVolume` - Volume up/down
- `XF86MonBrightnessUp/Down` - Brightness control

### Application Shortcuts
- `$mod+n` - Open file manager (Nautilus)
- `$mod+c` - Open calculator (SpeedCrunch)
- `$mod+p` - Open PyCharm

## Customising your install
You can edit any of the config files to your choosing. As the repo files are symlinked to each of their destination locations, you can run the appropriate `restore_*.sh` script to apply the changes. See the *Restore Scripts* section later.

### i3 Config
Location: `~/.config/i3/config`
- Window manager settings
- Key bindings
- Workspace configuration
- Application assignments

### Polybar Config
Location: `~/dotfiles/.config/polybar/config_Option[Option]`
- Status bar modules
- Colors and themes
- System monitoring
- Media player integration

Switch themes like this:

```shell
cd /dotfiles/.config/polybar
./switch-theme.sh
```

### Rofi Config
Location: `~/.config/rofi/config.rasi`
- Application launcher styling
- Color scheme
- Layout configuration

### Restore Scripts
- **Full restore**: [install.sh](install.sh) — one-time installer (packages, fonts, wallpapers, symlinks, makes scripts executable).
- **Config deploy**: [dotfiles/restore_config.sh](dotfiles/restore_config.sh) — creates backups of existing configs and symlinks repository configs into `~/.config` and `~/.bin`.
- **Terminal restore**: [restore_terminal.sh](restore_terminal.sh) — installs Zsh configuration and applies terminal settings.
- **Polybar launcher**: [dotfiles/.config/polybar/launch.sh](dotfiles/.config/polybar/launch.sh) — starts polybar using the selected `POLYBAR_OPTION` (default: Option5).

### Utility scripts
There are a number of utility scripts in the repo to enhance the experience:
- **lockpretty.sh**: pretty i3lock wrapper using a background image ([dotfiles/.bin/scripts/lockpretty.sh](dotfiles/.bin/scripts/lockpretty.sh)).
- **lockpixelate.sh**: pixelated lock screen using scrot + imagemagick ([dotfiles/.bin/scripts/lockpixelate.sh](dotfiles/.bin/scripts/lockpixelate.sh)).
- **screen_settings.sh**: basic X screen settings (DPMS off, screensaver off) ([dotfiles/.bin/scripts/screen_settings.sh](dotfiles/.bin/scripts/screen_settings.sh)).
- **Polybar scripts (per theme)**:
   - `pub-ipv4.sh` - Public IP display

Install to `~/.bin/scripts/` with [dotfiles/restore_config.sh](dotfiles/restore_config.sh).

## Notes & Tips
- The repo uses symlinks for deployment; editing files under `dotfiles/` and re-running [dotfiles/restore_config.sh](dotfiles/restore_config.sh) or reloading i3 will apply changes.
- For i3-gaps on Debian/Ubuntu you may need the i3-gaps PPA or to build from source; see comments in [minimum_packages.txt](minimum_packages.txt).
- If you prefer a fully dry-run before making changes, tell me and I can re-run the restore with `gsettings` and other commands mocked to avoid any live changes.

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
