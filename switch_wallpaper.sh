#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
I3_CONFIG="${I3_CONFIG:-$HOME/.config/i3/config}"

if [[ ! -d "$WALLPAPER_DIR" ]]; then
  echo "Wallpaper directory not found: $WALLPAPER_DIR" >&2
  exit 1
fi

mapfile -d '' wallpapers < <(
  find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -print0 | sort -z
)

if [[ ${#wallpapers[@]} -eq 0 ]]; then
  echo "No JPG/JPEG wallpapers found in: $WALLPAPER_DIR" >&2
  exit 1
fi

choose_with_whiptail() {
  local options=()
  local index

  for index in "${!wallpapers[@]}"; do
    options+=("$((index + 1))" "$(basename "${wallpapers[$index]}")")
  done

  local choice
  choice=$(whiptail \
    --title "Switch Wallpaper" \
    --menu "Choose a wallpaper" \
    22 90 14 \
    "${options[@]}" \
    3>&1 1>&2 2>&3) || return 1

  selected="${wallpapers[$((choice - 1))]}"
  return 0
}

choose_with_fzf() {
  local choice
  choice=$(printf '%s\n' "${wallpapers[@]}" | fzf --height=70% --layout=reverse --border --prompt="Wallpaper > ") || return 1
  selected="$choice"
  return 0
}

selected=""
if command -v whiptail >/dev/null 2>&1; then
  choose_with_whiptail || {
    echo "Selection cancelled."
    exit 130
  }
elif command -v fzf >/dev/null 2>&1; then
  choose_with_fzf || {
    echo "Selection cancelled."
    exit 130
  }
else
  echo "whiptail/fzf not found; using basic selector."
  echo "Choose a wallpaper:"
  PS3="Enter a number (or Ctrl+C to cancel): "
  select choice in "${wallpapers[@]}"; do
    if [[ -n "${choice:-}" ]]; then
      selected="$choice"
      break
    fi
    echo "Invalid selection. Try again." >&2
  done
fi

if [[ ! -f "$I3_CONFIG" ]]; then
  echo "i3 config not found: $I3_CONFIG" >&2
  exit 1
fi

cp "$I3_CONFIG" "$I3_CONFIG.bak"

escaped_selected=$(printf '%s' "$selected" | sed 's/[\\&]/\\\\&/g')

if grep -Eq '^[[:space:]]*exec(_always)?[[:space:]].*feh[[:space:]].*--bg-(fill|max|scale|tile|center)' "$I3_CONFIG"; then
  sed -E -i \
    "s#^([[:space:]]*exec(_always)?[[:space:]].*feh[[:space:]].*--bg-(fill|max|scale|tile|center)[[:space:]]+)(\"[^\"]*\"|'[^']*'|[^[:space:]]+)#\\1\"$escaped_selected\"#" \
    "$I3_CONFIG"
else
  printf '\nexec_always --no-startup-id feh --bg-fill "%s"\n' "$selected" >> "$I3_CONFIG"
fi

if command -v i3-msg >/dev/null 2>&1; then
  if i3-msg restart >/dev/null 2>&1; then
    echo "Wallpaper set in i3 config and i3 restarted: $selected"
    exit 0
  fi
fi

echo "Wallpaper set in i3 config: $selected"
echo "Could not restart i3 automatically. Run: i3-msg restart"
exit 0
