#!/bin/bash
#######################################################
# Linux Setup Configuration Restore Script
# Author: Murray Buchanan
# 
# This script restores all dotfiles and configurations
# to their proper locations for a fresh Linux install
#######################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Linux Setup Configuration Restore${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to print status messages
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Function to safely backup existing files
backup_if_exists() {
    local target=$1
    if [ -e "$target" ]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing $target to $backup"
        mv "$target" "$backup"
    fi
}

# Function to create symlink
create_symlink() {
    local source=$1
    local target=$2
    
    # Create parent directory if it doesn't exist
    local target_dir=$(dirname "$target")
    mkdir -p "$target_dir"
    
    # Backup existing file/directory
    backup_if_exists "$target"
    
    # Create symlink
    ln -sf "$source" "$target"
    print_status "Linked: $target -> $source"
}

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    print_error "Dotfiles directory not found at: $DOTFILES_DIR"
    exit 1
fi

echo -e "${BLUE}Installing configurations...${NC}"
echo ""

# Restore i3 configuration
if [ -d "$DOTFILES_DIR/.config/i3" ]; then
    print_status "Restoring i3 window manager config..."
    create_symlink "$DOTFILES_DIR/.config/i3" "$HOME/.config/i3"
fi

# Restore polybar configuration
if [ -d "$DOTFILES_DIR/.config/polybar" ]; then
    print_status "Restoring polybar config..."
    create_symlink "$DOTFILES_DIR/.config/polybar" "$HOME/.config/polybar"
    
    # Make polybar scripts executable
    find "$DOTFILES_DIR/.config/polybar" -type f -name "*.sh" -exec chmod +x {} \;
    print_status "Made polybar scripts executable"
fi

# Restore rofi configuration
if [ -d "$DOTFILES_DIR/.config/rofi" ]; then
    print_status "Restoring rofi config..."
    create_symlink "$DOTFILES_DIR/.config/rofi" "$HOME/.config/rofi"
fi

# Restore picom configuration
if [ -d "$DOTFILES_DIR/.config/picom" ]; then
    print_status "Restoring picom compositor config..."
    create_symlink "$DOTFILES_DIR/.config/picom" "$HOME/.config/picom"
fi

# Restore custom scripts
if [ -d "$DOTFILES_DIR/.bin" ]; then
    print_status "Restoring custom scripts..."
    create_symlink "$DOTFILES_DIR/.bin" "$HOME/.bin"
    
    # Make all scripts executable
    find "$DOTFILES_DIR/.bin" -type f -name "*.sh" -exec chmod +x {} \;
    print_status "Made custom scripts executable"
fi

# Restore fonts (if any custom fonts exist)
if [ -d "$SCRIPT_DIR/fonts" ] && [ "$(ls -A $SCRIPT_DIR/fonts 2>/dev/null | grep -v 'placeholder\|README')" ]; then
    print_status "Installing custom fonts..."
    mkdir -p "$HOME/.local/share/fonts"
    
    # Copy font files (excluding placeholder and README)
    find "$SCRIPT_DIR/fonts" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "$HOME/.local/share/fonts/" \;
    
    # Refresh font cache
    fc-cache -f -v > /dev/null 2>&1
    print_status "Fonts installed and cache refreshed"
fi

# Restore wallpapers
if [ -d "$SCRIPT_DIR/Wallpapers" ]; then
    print_status "Restoring wallpapers..."
    mkdir -p "$HOME/Pictures/Wallpapers"
    
    # Copy wallpapers (excluding placeholder files)
    find "$SCRIPT_DIR/Wallpapers" -type f ! -name "placeholder.txt" -exec cp {} "$HOME/Pictures/Wallpapers/" \;
    print_status "Wallpapers copied to ~/Pictures/Wallpapers"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Configuration restore complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Install required packages from packages.txt:"
echo "   ${BLUE}sudo apt install \$(cat $SCRIPT_DIR/packages.txt)${NC}"
echo ""
echo "2. Set your preferred polybar theme:"
echo "   ${BLUE}export POLYBAR_OPTION=\"Option4-Green\"${NC}  # or Option1, Option2, Option3 - Nordic"
echo "   Add to ~/.bashrc or ~/.zshrc to make it permanent"
echo ""
echo "3. Reload i3 configuration:"
echo "   ${BLUE}\$mod+Shift+r${NC}  (default: Super+Shift+r)"
echo ""
echo "4. Check setup notes:"
echo "   ${BLUE}cat $SCRIPT_DIR/notes/setup_notes.md${NC}"
echo ""
echo -e "${GREEN}Enjoy your setup!${NC}"
