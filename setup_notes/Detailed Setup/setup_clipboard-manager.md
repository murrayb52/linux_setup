# Clipboard Manager Setup (Clipster + Rofi)

## Overview
This setup provides a Windows 11-style clipboard history manager using Clipster and Rofi. The clipboard menu appears directly below your cursor, similar to polybar WiFi/BT buttons.

## Features
- ✅ Automatic clipboard history tracking (last 20 items)
- ✅ Rofi menu appears below cursor position
- ✅ Auto-paste selected item
- ✅ Lightweight and keyboard-driven
- ✅ Integrates seamlessly with i3wm workflow

## Installation

### 1. Install Required Packages
```bash
sudo apt install -y rofi xdotool xclip
```

### 2. Install Clipster
```bash
# Clone and install clipster
git clone https://github.com/mrichar1/clipster.git /tmp/clipster
sudo cp /tmp/clipster/clipster /usr/local/bin/
sudo chmod +x /usr/local/bin/clipster

# Fix shebang for Python 3
sudo sed -i '1s|#!/usr/bin/python|#!/usr/bin/python3|' /usr/local/bin/clipster
```

### 3. Configure i3
The following should already be in your i3 config after restore:

```bash
# Clipster + Rofi Clipboard Manager
exec --no-startup-id clipster -d
bindsym $mod+shift+v split v
bindsym $mod+v exec --no-startup-id ~/.config/rofi/clipboard.sh
```

**Note:** This changes `$mod+v` from "split vertical" to "open clipboard". Use `$mod+Shift+v` for split vertical instead.

### 4. Script Location
The clipboard script is located at: `~/.config/rofi/clipboard.sh`

## Usage

### Basic Operations
- **Copy text**: Use `Ctrl+C` as normal (history is automatically tracked)
- **Open clipboard menu**: Press `$mod+v` (Windows key + V)
- **Select item**: Use arrow keys or type to search, press Enter
- **Auto-paste**: Selected item is automatically pasted at cursor position

### How It Works
1. Clipster daemon runs in the background and monitors clipboard
2. When you press `$mod+v`:
   - Script gets current cursor position
   - Opens rofi menu 20 pixels below cursor
   - Shows last 20 clipboard items
3. When you select an item:
   - Item is copied to clipboard
   - Automatically pastes using Shift+Insert

## Customization

### Change Number of History Items
Edit `~/.config/rofi/clipboard.sh` and change `-n 20` to your preferred number:
```bash
clipster -o -n 50  # Show last 50 items
```

### Adjust Menu Position
In `clipboard.sh`, modify these values:
```bash
-xoffset $((X - 300))  # Horizontal offset (centers 600px window)
-yoffset $((Y + 20))   # Vertical offset (pixels below cursor)
```

### Change Menu Width
Modify the window width in the theme string:
```bash
-theme-str 'window {width: 800px;}'
```

### Configure Clipster
Create `~/.clipster.rc` for advanced configuration:
```ini
[clipster]
# Maximum number of items to store
hist_size = 200

# Path to history file
history_file = ~/.local/share/clipster/history

# Ignore patterns (regex)
ignore_patterns = ^Password$, ^Secret$
```

## Troubleshooting

### Menu Doesn't Appear
```bash
# Check if clipster is running
pgrep -a clipster

# If not, start it manually
clipster -d &
```

### Wrong Python Version Error
```bash
# Fix shebang
sudo sed -i '1s|#!/usr/bin/python|#!/usr/bin/python3|' /usr/local/bin/clipster
```

### Paste Not Working
Ensure xdotool and xclip are installed:
```bash
sudo apt install -y xdotool xclip
```

### Menu Position Off
Adjust the offset values in `clipboard.sh` based on your screen setup.

## Key Bindings

| Action | Keybinding |
|--------|-----------|
| Open clipboard menu | `$mod+v` |
| Split vertical | `$mod+Shift+v` |
| Copy (standard) | `Ctrl+C` |
| Paste (standard) | `Ctrl+V` or `Shift+Insert` |

## Comparison with Other Options

### Why Clipster + Rofi?
- **Lightweight**: Minimal resource usage
- **Keyboard-driven**: Perfect for i3wm workflow
- **Cursor positioning**: Appears exactly where you need it
- **Similar to polybar**: Matches existing WiFi/BT button style
- **No Qt dependencies**: Unlike CopyQ

### Alternative: CopyQ
If you prefer a GUI with more features:
```bash
sudo apt install -y copyq
bindsym $mod+v exec --no-startup-id copyq toggle
exec --no-startup-id copyq
```

## Integration with Polybar

You can optionally add a polybar module:

```ini
[module/clipboard]
type = custom/text
content = 📋
click-left = ~/.config/rofi/clipboard.sh
tooltip-text = "Clipboard Manager ($mod+v)"
```

Then add `clipboard` to your polybar modules list.

## Files Modified

- `~/.config/i3/config` - Added keybindings and clipster autostart
- `~/.config/rofi/clipboard.sh` - Clipboard menu script (NEW)
- `/usr/local/bin/clipster` - Clipboard manager daemon (installed)

## Author

Setup by Murray Buchanan - February 2026

## References

- [Clipster GitHub](https://github.com/mrichar1/clipster)
- [Rofi Documentation](https://github.com/davatorium/rofi)
- [xdotool Manual](https://www.semicomplete.com/projects/xdotool/)
