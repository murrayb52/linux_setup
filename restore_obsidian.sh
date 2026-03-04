#!/usr/bin/env bash
set -u

# restore_obsidian.sh
# - Symlink minimal setup notes into an Obsidian Vault
# - Optionally install and enable Syncthing (user service)
# - Print interactive/headless instructions where appropriate

echo "Running Obsidian restore..."

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_ROOT/setup_notes"
if [ ! -d "$SRC" ]; then
  echo "ERROR: expected setup notes at: $SRC"
  echo "Please create the symlink manually, for example:"
  echo
  echo "  mkdir -p \"$HOME/ObsidianVault/Linux\""
  echo "  ln -s \"$REPO_ROOT/setup_notes\" \"$HOME/ObsidianVault/Linux/Setup\""
  exit 1
fi

TARGET="$HOME/ObsidianVault/Linux/Setup"
echo "Creating symlink: $TARGET -> $SRC"
mkdir -p "$(dirname "$TARGET")" || echo "WARNING: failed to create parent dir"
ln -sfn "$SRC" "$TARGET" || echo "ERROR: failed to create symlink"
echo "Done. Symlink created (or replaced)."

# Install SyncThing (responsible for syncing the Obsidian vault across devices)
echo "Installing Syncthing..."
sudo apt install syncthing

# Enable lingering so SyncThing runs when not logged in:
sudo loginctl enable-linger $USER

# Enable and start the user service (run in a logged-in graphical session):
systemctl --user enable syncthing.service
systemctl --user start syncthing.service


cat <<'INSTR'
== Manually complete the following: ==

Access the web UI at: http://127.0.0.1:8384/

Pair desktop to phone:
 - On phone: Actions → Show ID
 - On this device: Add Device, paste or scan Device ID
 - Select the folder named 'ObsidianVault' (or create it on the sending device)
 - Optionally enable 'Auto Accept' for trusted devices

INSTR

echo "Finished. Open Obsidian and point your vault to ~/ObsidianVault (or the subfolder Linux/Setup)."
