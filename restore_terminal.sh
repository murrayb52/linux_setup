#!/bin/bash
#######################################################
# Restore terminal and Zsh configuration
# - backs up existing zsh files
# - installs .zshrc and Powerlevel10k config
# - installs MesloLGS Nerd Font
# - configures GNOME Terminal (if present)
#######################################################

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

echo "=========================================="
echo "  Terminal & Zsh Configuration Restore"
echo "=========================================="
echo ""

BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Creating backup of existing shell configs..."
[ -f ~/.zshrc ] && cp ~/.zshrc "$BACKUP_DIR/" || true
[ -f ~/.p10k.zsh ] && cp ~/.p10k.zsh "$BACKUP_DIR/" || true
echo "✓ Backup created at: $BACKUP_DIR"

if [ -d "$DOTFILES_DIR/zsh" ]; then
    echo "Installing ZSH configurations..."
    cp "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc
    cp "$DOTFILES_DIR/zsh/.p10k.zsh" ~/.p10k.zsh
    echo "✓ ZSH configs installed"
fi

# Configure gnome-terminal if available
echo ""
if command -v gsettings &> /dev/null && gsettings list-schemas | grep -q "org.gnome.Terminal"; then
    echo "Configuring gnome-terminal..."
    PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ use-theme-colors false
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ background-color '#282828'
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ foreground-color '#FFFFFF'
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ use-transparent-background true
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ background-transparency-percent 15
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ use-system-font false
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ font 'Monospace 10'
    gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar false
    echo "✓ Gnome-terminal configured (dark grey, white text, 85% opacity, no menu bar)"
else
    echo "⚠ Gnome-terminal not found, skipping terminal configuration"
fi

echo ""
echo "Terminal restore complete."
