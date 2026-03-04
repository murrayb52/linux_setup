#!/bin/bash
#######################################################
# Linux Setup Full Restore Script
# Calls `dotfiles/restore_config.sh` for polybar/i3/rofi
# and performs the other local restore tasks (fonts, wallpapers, .bin)
#######################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Linux Setup Full Restore${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

backup_if_exists() {
    local target=$1
    if [ -e "$target" ]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing $target to $backup"
        mv "$target" "$backup"
    fi
}

create_symlink() {
    local source=$1
    local target=$2
    local target_dir
    target_dir=$(dirname "$target")
    mkdir -p "$target_dir"
    backup_if_exists "$target"
    ln -sf "$source" "$target"
    print_status "Linked: $target -> $source"
}

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    print_error "Dotfiles directory not found at: $DOTFILES_DIR"
    exit 1
fi

# Make all scripts in the repo executable (safe one-time step)
print_status "Making all .sh scripts executable in the repository"
find "$SCRIPT_DIR" -type f -name "*.sh" -exec chmod +x {} \; || true
print_status "Executable bits set for .sh files"

echo -e "${BLUE}Installing minimum packages...${NC}"

# Parse minimum_packages.txt and install packages
PKG_FILE="$SCRIPT_DIR/minimum_packages.txt"
if [ -f "$PKG_FILE" ]; then
    packages=()
    while IFS= read -r line || [ -n "$line" ]; do
        line="${line%%#*}"
        line="$(echo "$line" | tr -d '\r')"
        line="$(echo "$line" | xargs)"
        if [ -n "$line" ]; then
            pkg="$(echo "$line" | awk '{print $1}')"
            if [ -n "$pkg" ]; then
                packages+=("$pkg")
            fi
        fi
    done < "$PKG_FILE"

    if [ ${#packages[@]} -gt 0 ]; then
        # Install packages from the list (use distro i3 package, not i3-gaps)
        echo "Packages to install: ${packages[*]}"
        echo "Updating package cache (sudo required)..."
        sudo apt update
        echo "Installing packages (sudo required)..."
        sudo apt install -y "${packages[@]}"
    else
        echo "No packages found in $PKG_FILE"
    fi
else
    echo "Package list not found: $PKG_FILE"
fi

echo -e "${BLUE}Running config-level restore (polybar/i3/rofi)...${NC}"
bash "$DOTFILES_DIR/restore_config.sh"

echo -e "${BLUE}Running terminal & zsh restore...${NC}"
bash "$SCRIPT_DIR/restore_terminal.sh"

# Offer to set up Obsidian sync via Syncthing
echo ""
read -r -p "Set up Obsidian sync with Syncthing now? [y/N] " RESP
case "$RESP" in
    [yY]|[yY][eE][sS])
        if [ -x "$SCRIPT_DIR/restore_obsidian.sh" ]; then
            bash "$SCRIPT_DIR/restore_obsidian.sh"
        else
            print_warning "restore_obsidian.sh not found or not executable: $SCRIPT_DIR/restore_obsidian.sh"
        fi
        ;;
    *)
        print_status "Skipping Obsidian sync setup"
        ;;
esac

echo -e "${BLUE}Installing configurations...${NC}"
echo ""

# Note: picom and .bin are restored by dotfiles/restore_config.sh

# Restore fonts (if any custom fonts exist)
if [ -d "$SCRIPT_DIR/fonts" ] && [ "$(ls -A $SCRIPT_DIR/fonts 2>/dev/null | grep -v 'placeholder\|README')" ]; then
    print_status "Installing custom fonts..."
    mkdir -p "$HOME/.local/share/fonts"
    find "$SCRIPT_DIR/fonts" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "$HOME/.local/share/fonts/" \;
    fc-cache -f -v > /dev/null 2>&1
    print_status "Fonts installed and cache refreshed"
fi

# Download and install MesloLGS Nerd Font for terminal icons (once-off)
echo ""
print_status "Installing MesloLGS Nerd Font (for Powerlevel10k)"
mkdir -p ~/.local/share/fonts
if command -v wget &> /dev/null; then
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -O ~/.local/share/fonts/MesloLGS_NF_Regular.ttf 2>/dev/null || true
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf -O ~/.local/share/fonts/MesloLGS_NF_Bold.ttf 2>/dev/null || true
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf -O ~/.local/share/fonts/MesloLGS_NF_Italic.ttf 2>/dev/null || true
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf -O ~/.local/share/fonts/MesloLGS_NF_Bold_Italic.ttf 2>/dev/null || true
    fc-cache -f -v > /dev/null 2>&1
    print_status "MesloLGS fonts installed"
else
    print_warning "wget not found; skipping MesloLGS font download"
fi

# Restore wallpapers
if [ -d "$SCRIPT_DIR/Wallpapers" ]; then
    print_status "Restoring wallpapers..."
    mkdir -p "$HOME/Pictures/Wallpapers"
    find "$SCRIPT_DIR/Wallpapers" -type f ! -name "placeholder.txt" -exec cp {} "$HOME/Pictures/Wallpapers/" \;
    print_status "Wallpapers copied to ~/Pictures/Wallpapers"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Full configuration restore complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "1. Log into i3 again:"
echo -e "   ${BLUE}\$mod+Shift+r${NC}  (default: Super+Shift+r)"
echo ""
echo "2. View setup notes for more configuration information and troubleshooting tips:"
echo -e "   ${BLUE}cat $SCRIPT_DIR/setup_notes/Quick\ Setup.md${NC}"
echo ""
echo -e "${GREEN}Enjoy your setup!${NC}"
