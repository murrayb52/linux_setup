# ZSH Configuration

This directory contains customized ZSH configuration files using Powerlevel10k theme.

## Files

- `.zshrc` - Main ZSH configuration file
- `.p10k.zsh` - Powerlevel10k theme configuration

## Installation

Copy these files to your home directory:

```bash
cp .zshrc ~/.zshrc
cp .p10k.zsh ~/.p10k.zsh
source ~/.zshrc
```

Or run the `restore_config.sh` script from the dotfiles root.

## Configuration Details

### .zshrc
- Sets Polybar theme option (Option4 by default)
- Configures Oh-My-Zsh with Powerlevel10k theme
- Sets custom LS_COLORS with green directories
- Loads Powerlevel10k configuration from `.p10k.zsh`

### .p10k.zsh (Powerlevel10k Theme)
- **Left Prompt**: Directory only (no OS icon, no git status)
- **Right Prompt**: Status, execution time, background jobs, virtualenv, and other context
- **Colors**: Green background for directory (color 2)
- **Simplified**: Git/VCS segment removed for cleaner look

## Terminal Settings

For the full experience, configure gnome-terminal:

**Font:**
- Monospace 10 (or any monospace font)
- MesloLGS NF if you need Nerd Font icons

**Colors:**
- Background: #282828 (dark grey)
- Foreground: #FFFFFF (white)
- Transparency: 85% opacity

**Settings:**
- Menu bar: Hidden
- Use theme colors: Disabled

These terminal settings are automatically applied by the `restore_config.sh` script.

## Prerequisites

- Oh-My-Zsh: https://ohmyz.sh/
- Powerlevel10k: https://github.com/romkatv/powerlevel10k

Install with:
```bash
# Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

## Customization

To reconfigure Powerlevel10k:
```bash
p10k configure
```

To change colors, edit `.p10k.zsh` and modify:
- `POWERLEVEL9K_DIR_BACKGROUND` - Directory background color (2=green, 4=blue, etc.)
- Add/remove prompt elements in `POWERLEVEL9K_LEFT_PROMPT_ELEMENTS`
