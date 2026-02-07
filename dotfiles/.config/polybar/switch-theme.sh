#!/bin/bash
# Polybar theme switcher
# Quick helper to switch between polybar themes

POLYBAR_DIR="$HOME/.config/polybar"

# Available themes
THEMES=("Option1" "Option2" "Option3 - Nordic" "Option4-Green")

echo "=========================================="
echo "  Polybar Theme Switcher"
echo "=========================================="
echo ""
echo "Available themes:"
for i in "${!THEMES[@]}"; do
    echo "  $((i+1)). ${THEMES[$i]}"
done
echo ""

# Get current theme
CURRENT="${POLYBAR_OPTION:-Option4-Green}"
echo "Current theme: $CURRENT"
echo ""

# Prompt for selection
read -p "Select theme (1-${#THEMES[@]}) or press Enter to keep current: " choice

if [ -z "$choice" ]; then
    echo "Keeping current theme: $CURRENT"
    exit 0
fi

# Validate input
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#THEMES[@]}" ]; then
    echo "Error: Invalid selection"
    exit 1
fi

# Get selected theme
SELECTED="${THEMES[$((choice-1))]}"

echo ""
echo "Switching to: $SELECTED"
echo ""

# Update the environment variable
export POLYBAR_OPTION="$SELECTED"

# Restart polybar
echo "Restarting polybar..."
killall -q polybar
sleep 1
"$POLYBAR_DIR/launch.sh" &

echo ""
echo "✓ Theme switched successfully!"
echo ""
echo "To make this permanent, add this to your ~/.bashrc or ~/.zshrc:"
echo "  export POLYBAR_OPTION=\"$SELECTED\""
echo ""
