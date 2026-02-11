#!/bin/bash
# Author: Murray Buchanan
# Restore all dotfiles configurations to the system

set -e  # Exit on error

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$SCRIPT_DIR"

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
[ -f ~/.zshrc ] && cp ~/.zshrc "$BACKUP_DIR/"
[ -f ~/.p10k.zsh ] && cp ~/.p10k.zsh "$BACKUP_DIR/"
[ -d ~/.config/polybar ] && cp -r ~/.config/polybar "$BACKUP_DIR/"
[ -d ~/.config/i3 ] && cp -r ~/.config/i3 "$BACKUP_DIR/"
[ -d ~/.config/picom ] && cp -r ~/.config/picom "$BACKUP_DIR/"
[ -d ~/.config/rofi ] && cp -r ~/.config/rofi "$BACKUP_DIR/"
[ -d ~/.bin ] && cp -r ~/.bin "$BACKUP_DIR/"

echo "✓ Backup created at: $BACKUP_DIR"
echo ""

# Install ZSH configs
echo "Installing ZSH configurations..."
cp "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc
cp "$DOTFILES_DIR/zsh/.p10k.zsh" ~/.p10k.zsh
echo "✓ ZSH configs installed"

# Install .config directories
echo ""
echo "Installing .config directories..."
mkdir -p ~/.config

# Polybar
if [ -d "$DOTFILES_DIR/.config/polybar" ]; then
    cp -r "$DOTFILES_DIR/.config/polybar" ~/.config/
    chmod +x ~/.config/polybar/*.sh
    echo "✓ Polybar config installed"
fi

# i3
if [ -d "$DOTFILES_DIR/.config/i3" ]; then
    cp -r "$DOTFILES_DIR/.config/i3" ~/.config/
    echo "✓ i3 config installed"
fi

# Picom
if [ -d "$DOTFILES_DIR/.config/picom" ]; then
    cp -r "$DOTFILES_DIR/.config/picom" ~/.config/
    echo "✓ Picom config installed"
fi

# Rofi
if [ -d "$DOTFILES_DIR/.config/rofi" ]; then
    cp -r "$DOTFILES_DIR/.config/rofi" ~/.config/
    chmod +x ~/.config/rofi/*.sh
    chmod +x ~/.config/rofi/scripts/*.sh
    echo "✓ Rofi config installed (Kanagawa Dragon theme)"
fi

# Install .bin scripts
echo ""
echo "Installing bin scripts..."
if [ -d "$DOTFILES_DIR/.bin" ]; then
    cp -r "$DOTFILES_DIR/.bin" ~/
    chmod +x ~/.bin/scripts/*.sh
    echo "✓ Bin scripts installed"
fi

# Install fonts
echo ""
echo "Installing fonts..."
if [ -d "$DOTFILES_DIR/fonts" ] && [ -n "$(ls -A $DOTFILES_DIR/fonts/*.ttf 2>/dev/null)" ]; then
    mkdir -p ~/.local/share/fonts
    cp "$DOTFILES_DIR/fonts"/*.ttf ~/.local/share/fonts/ 2>/dev/null || true
    fc-cache -f ~/.local/share/fonts
    echo "✓ Fonts installed"
else
    echo "⚠ No fonts found in fonts directory"
fi

# Download and install MesloLGS Nerd Font for terminal icons
echo ""
echo "Installing MesloLGS Nerd Font..."
mkdir -p ~/.local/share/fonts
cd /tmp
if command -v wget &> /dev/null; then
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -O ~/.local/share/fonts/MesloLGS_NF_Regular.ttf 2>/dev/null || echo "⚠ Could not download font"
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf -O ~/.local/share/fonts/MesloLGS_NF_Bold.ttf 2>/dev/null || true
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf -O ~/.local/share/fonts/MesloLGS_NF_Italic.ttf 2>/dev/null || true
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf -O ~/.local/share/fonts/MesloLGS_NF_Bold_Italic.ttf 2>/dev/null || true
    fc-cache -f ~/.local/share/fonts
    echo "✓ MesloLGS Nerd Font installed"
fi
cd "$DOTFILES_DIR"

# Install wallpapers
echo ""
echo "Installing wallpapers..."
if [ -d "$DOTFILES_DIR/Wallpapers" ]; then
    mkdir -p ~/Pictures/Wallpapers
    cp "$DOTFILES_DIR/Wallpapers"/* ~/Pictures/Wallpapers/ 2>/dev/null || true
    echo "✓ Wallpapers installed"
fi

# Configure gnome-terminal if available
echo ""
if command -v gsettings &> /dev/null && gsettings list-schemas | grep -q "org.gnome.Terminal"; then
    echo "Configuring gnome-terminal..."
    
    PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
    
    # Set colors
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ use-theme-colors false
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ background-color '#282828'
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ foreground-color '#FFFFFF'
    
    # Set transparency
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ use-transparent-background true
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ background-transparency-percent 15
    
    # Set font
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ use-system-font false
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ font 'Monospace 10'
    
    # Hide menu bar
    gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar false
    
    echo "✓ Gnome-terminal configured (dark grey, white text, 85% opacity, no menu bar)"
else
    echo "⚠ Gnome-terminal not found, skipping terminal configuration"
fi

echo ""
echo "=========================================="
echo "  Installation Complete!"
echo "=========================================="
echo ""
echo "Backup location: $BACKUP_DIR"
echo ""
echo "Next steps:"
echo "1. Reload ZSH: source ~/.zshrc"
echo "2. Restart i3: \$mod+Shift+r"
echo "3. Open a new terminal to see the changes"
echo ""
echo "Notes:"
echo "- Polybar theme is set to Option5 by default"
echo "- Use 'switch-theme.sh' to change polybar themes"
echo "- Terminal has green directory highlighting"
echo ""
