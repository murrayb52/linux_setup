#!/bin/bash
# Author: Murray Buchanan
# Restore all dotfiles configurations to the system

set -e  # Exit on error

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$SCRIPT_DIR"

# Helper: backup existing file/dir if present
# Must MOVE the original out of the way, not copy it - if it's still there
# afterward, `ln -sfn` on an existing real directory nests the new symlink
# INSIDE it instead of replacing it, silently leaving the "symlink" a dead
# stray file and the live config a frozen copy disconnected from the repo.
# See setup_notes/dotfiles-symlinks-not-applied.md.
backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        local backup_dir="$BACKUP_DIR"
        mkdir -p "$backup_dir"
        local base=$(basename "$target")
        mv "$target" "$backup_dir/${base}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
}

# Helper: create symlink with backup of existing target
create_symlink() {
    local src="$1"
    local dst="$2"
    local dst_dir
    dst_dir=$(dirname "$dst")
    mkdir -p "$dst_dir"
    backup_if_exists "$dst"
    ln -sfn "$src" "$dst"
}

echo "=========================================="
echo "  Dotfiles Configuration Restore"
echo "=========================================="
echo ""
echo "This script will install all configurations from:"
echo "$DOTFILES_DIR"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Creating backup of existing configs..."
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup existing configs if they exist
[ -d ~/.config/polybar ] && cp -r ~/.config/polybar "$BACKUP_DIR/"
[ -d ~/.config/i3 ] && cp -r ~/.config/i3 "$BACKUP_DIR/"
[ -d ~/.config/picom ] && cp -r ~/.config/picom "$BACKUP_DIR/"
[ -d ~/.config/rofi ] && cp -r ~/.config/rofi "$BACKUP_DIR/"
[ -d ~/.bin ] && cp -r ~/.bin "$BACKUP_DIR/"

echo "✓ Backup created at: $BACKUP_DIR"
echo ""

# Install .config directories
echo ""
echo "Installing .config directories..."
mkdir -p ~/.config

# Polybar (create symlink to config directory)
if [ -d "$DOTFILES_DIR/.config/polybar" ]; then
    create_symlink "$DOTFILES_DIR/.config/polybar" "$HOME/.config/polybar"
    find "$HOME/.config/polybar" -type f -name "*.sh" -exec chmod +x {} \; || true
    echo "✓ Polybar config installed (symlink)"
fi

# i3 (create symlink to config directory)
if [ -d "$DOTFILES_DIR/.config/i3" ]; then
    create_symlink "$DOTFILES_DIR/.config/i3" "$HOME/.config/i3"
    echo "✓ i3 config installed (symlink)"
fi

# Picom (create symlink to config directory)
if [ -d "$DOTFILES_DIR/.config/picom" ]; then
    create_symlink "$DOTFILES_DIR/.config/picom" "$HOME/.config/picom"
    echo "✓ Picom config installed (symlink)"
fi

# Rofi (create symlink to config directory)
if [ -d "$DOTFILES_DIR/.config/rofi" ]; then
    create_symlink "$DOTFILES_DIR/.config/rofi" "$HOME/.config/rofi"
    find "$HOME/.config/rofi" -type f -name "*.sh" -exec chmod +x {} \; || true
    find "$HOME/.config/rofi/scripts" -type f -name "*.sh" -exec chmod +x {} \; || true
    echo "✓ Rofi config installed (symlink)"
fi

# Install .bin scripts (symlinked)
echo ""
echo "Installing bin scripts..."
if [ -d "$DOTFILES_DIR/.bin" ]; then
    create_symlink "$DOTFILES_DIR/.bin" "$HOME/.bin"
    find "$HOME/.bin" -type f -name "*.sh" -exec chmod +x {} \; || true
    echo "✓ Bin scripts installed (symlink)"
fi


# Install wallpapers
echo ""
echo "Installing wallpapers..."
if [ -d "$DOTFILES_DIR/Wallpapers" ]; then
    mkdir -p ~/Pictures/Wallpapers
    cp "$DOTFILES_DIR/Wallpapers"/* ~/Pictures/Wallpapers/ 2>/dev/null || true
    echo "✓ Wallpapers installed"
fi

# (Zsh and terminal customization moved to restore_terminal.sh)

echo ""
echo "=========================================="
echo "  Installation Complete!"
echo "=========================================="
echo ""
echo "Backup location: $BACKUP_DIR"
echo ""
echo "Restart i3 with: \$mod+Shift+r"
echo ""
echo "Notes:"
echo "- Polybar theme is set to Option5 by default"
echo "- Use 'switch-theme.sh' to change polybar themes"
echo ""
