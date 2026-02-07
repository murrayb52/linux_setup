# Issue: Polybar Not Showing on i3 Startup

## Problem
Polybar was not appearing when i3 window manager started, even though the launch script was configured in the i3 config.

## Root Cause
The issue was caused by two factors:
1. **Script permissions**: The `launch.sh` script didn't have execute permissions
2. **Missing theme environment variable**: Polybar config references `$POLYBAR_OPTION` which wasn't set

## Solution

### 1. Make Scripts Executable
```bash
chmod +x ~/.config/polybar/launch.sh
find ~/.config/polybar -type f -name "*.sh" -exec chmod +x {} \;
```

The [[restore.sh]] script now automatically handles this during setup:
```bash
# Make polybar scripts executable
find "$DOTFILES_DIR/.config/polybar" -type f -name "*.sh" -exec chmod +x {} \;
```

### 2. Set Polybar Theme
Add to `~/.bashrc` or `~/.zshrc`:
```bash
export POLYBAR_OPTION="Option4-Green"
```

Available themes:
- `Option1` - Default
- `Option2` - Alternative
- `Option3-Nordic` - Nordic theme
- `Option4-Green` - Green theme

After making changes, reload i3 with `$mod+Shift+r`

## Prevention
The restoration script has been updated to automatically:
- Set execute permissions on all polybar shell scripts
- Display instructions for setting the POLYBAR_OPTION variable

## Related Notes
- [[setup_notes]] - Main setup documentation
- [[issue-ipv4-polybar-module]] - IPv4 display script issues
