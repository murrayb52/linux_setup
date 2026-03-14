#!/bin/bash
# apply_themes.sh
# Copy all Polybar config_OptionX files into the real
# ~/.config/polybar directory and restart Polybar.

set -e

# Source directory: where this script lives (your dotfiles repo copy)
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Target directory: active Polybar config location
TARGET_DIR="$HOME/.config/polybar"

echo "=========================================="
echo "  Applying Polybar themes to ~/.config"
echo "=========================================="
echo "Source : $SOURCE_DIR"
echo "Target : $TARGET_DIR"
echo

mkdir -p "$TARGET_DIR"

# Copy all config_OptionX files
echo "Copying config_Option* files..."
cp -v "$SOURCE_DIR"/config_Option* "$TARGET_DIR"/

echo

# Restart Polybar using the target launch script if available
if command -v polybar-msg >/dev/null 2>&1; then
  echo "Stopping existing Polybar via polybar-msg..."
  polybar-msg cmd quit || true
else
  echo "Stopping existing Polybar via killall..."
  killall -q polybar || true
fi

sleep 1

if [ -x "$TARGET_DIR/launch.sh" ]; then
  echo "Starting Polybar using $TARGET_DIR/launch.sh..."
  "$TARGET_DIR/launch.sh" &
else
  echo "Warning: $TARGET_DIR/launch.sh not found or not executable."
  echo "Polybar configs have been copied, but you'll need to start Polybar manually."
fi

echo
echo "✓ Themes applied and Polybar restart attempted."
