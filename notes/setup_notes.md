# i3-gaps Setup Notes

These notes are intended to live happily in **Obsidian** and document a full i3-gaps–based Linux desktop setup, including tweaks, fixes, inspiration, and custom key mappings.

---

## i3-gaps

**Project**  
- https://github.com/Airblader/i3

**Speed Ricer (PPA)**  
- Ken Gilmer – https://launchpad.net/~kgilmer/+archive/ubuntu/speed-ricer

**Learning Resources**  
- *i3wm: Jump Start (1/3)* – Code Cast  
  https://www.youtube.com/watch?v=ARKIwOlazKI

---

## Installation

### Core Packages

- i3-gaps
- compton
- rofi
- feh
- playerctl
- i3lock
- i3status

```bash
chmod 777 ~/.config -R
```

### Restore Existing System

- Restore dotfiles from GitHub:  
  https://github.com/addy-dclxvi/dotfiles

---

# Obsidian + Git Repo Integration (Symlinked Notes)

This vault includes notes that live inside a **Git repository** but appear as part of the main Obsidian vault via a **symlink**.

This allows:
- Linux / infra notes to live in Git
- Everything else to sync via Syncthing
- A single Obsidian graph, search space, and backlink system

## Symlink Setup

### Goal
Expose repo-backed notes inside the Obsidian vault **without duplicating files**.

### Paths
- Obsidian vault: `~/ObsidianVault`
- Linux setup repo notes: `~/projects/linux-setup/linux-setup/notes`

### Create the symlink

```bash
ln -s ~/projects/linux-setup/linux-setup/notes \
      ~/ObsidianVault/Linux
```
```
## Common Issues & Fixes

> 📚 **See [[troubleshooting-index]] for a complete list of resolved issues**

### Recent Issues (See Detailed Notes)
- [[issue-i3-taskbar-not-visible]] - Status bar/taskbar not showing on startup
- [[issue-polybar-not-showing]] - Polybar configuration and permissions
- [[issue-ipv4-polybar-module]] - IPv4 address display script fix

### Pywal (theme colors)

Pywal is not in the default Ubuntu repos. Install it via **pipx** and ensure PATH is set.

```bash
sudo apt install pipx
pipx install pywal
pipx ensurepath
```

Open a new terminal (or re-login), then generate colors:

```bash
wal -i ~/Pictures/Wallpapers/GreenLeaves4.jpg
```

If `wal` isn't found, ensure this exists in `~/.zshrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Powerlevel10k theme not found

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### apt update fails (broken PPA)

If `apt update` fails with a missing Release file (e.g. `gezakovacs` PPA), remove it:

```bash
sudo add-apt-repository -r ppa:gezakovacs/ppa
```

### Dotfiles
- Restore `.config/i3/config`

### i3status Error

```bash
mkdir -p ~/.i3
touch ~/.i3/i3blocks.config
```

### i3lock
- Background images: `~/.xlock`
- Scripts: `~/.bin/scripts/lockpretty.sh` or `lockpixelate.sh`

```bash
chmod a+x lockpretty.sh
mkdir ~/.xlock
# add wallpaper.jpg
```

---

## Cinnamon Desktop Backup

**Guide**  
https://www.addictivetips.com/ubuntu-linux-tips/backup-the-cinnamon-desktop-settings-on-linux/

### Backup
```bash
dconf dump /org/cinnamon/ > cinnamon_desktop_backup
```

### Restore
```bash
dconf load /org/cinnamon/ < cinnamon_desktop_backup
```

Log out or restart if the DE crashes.

### Reset
```bash
dconf reset /org/cinnamon/
# if that fails
dconf reset -f /org/cinnamon/
```

---

## Tweaks

### Firefox
- Enable autoscrolling (middle-click scroll)

### Spotify (i3 Workspace Assignment)
Spotify does not set window hints correctly.

Reference: https://github.com/i3/i3/issues/2060

```text
for_window [class="Spotify"] move to workspace $ws10
```

---

## Custom Key Mapping

### Right Alt + Escape → `~`

Useful for **tenkeyless keyboards**.

#### Create XKB Symbol
```bash
sudo nano /usr/share/X11/xkb/symbols/custom
```

```text
partial alphanumeric_keys
xkb_symbols "ralt_esc_tilde" {
    key <ESC> {
        type = "FOUR_LEVEL",
        symbols[Group1] = [ Escape, Escape, asciitilde, asciitilde ]
    };
};
```

#### Enable Mapping
```bash
setxkbmap -layout us \
  -option lv3:ralt_switch \
  -option custom:ralt_esc_tilde
```

#### Persist in i3
Add to `~/.config/i3/config`:

```text
exec_always --no-startup-id setxkbmap -layout us -option lv3:ralt_switch -option custom:ralt_esc_tilde
```

---

## Virtual Environments

**Install Specific Django Version**  
https://www.howtoforge.com/tutorial/how-to-install-django-on-ubuntu/

---

## Mouse Bindings

Detect mouse buttons:
```bash
xev | grep button
```

Apply binding regardless of cursor position:
```text
bindsym --whole-window button8 exec playerctl play-pause
```

---

## Media Key Bindings

Install CLI media controls:
```bash
sudo apt install playerctl
```

Determine keycodes:
```bash
xmodmap -pke
```

Reference:  
https://faq.i3wm.org/question/3747/enabling-multimedia-keys.1.html

---

## Polybar

- i3 module actions:  
  https://polybar.readthedocs.io/en/stable/user/actions.html#internal-i3
- Workspace label fallback:  
  https://www.reddit.com/r/Polybar/comments/b5d8ml/polybar_workspace_label/
- Fonts:  
  https://github.com/polybar/polybar/wiki/Fonts
- Temperature module:  
  https://github.com/polybar/polybar/wiki/Module:-temperature

---

## Fonts

- Font Awesome: https://github.com/FortAwesome/Font-Awesome
- Cozette: https://github.com/slavfox/Cozette

Refresh font cache:
```bash
fc-cache ~/.fonts
```

---

## Inspiration

- https://github.com/kanishkarj/i3-config
- https://www.reddit.com/r/unixporn/comments/ln0ik7/
- https://www.reddit.com/r/unixporn/comments/791cw8/
- https://www.reddit.com/r/unixporn/comments/7wyzl1/
- https://www.reddit.com/r/unixporn/comments/b2fgij/
- https://www.reddit.com/r/unixporn/comments/m2dyqu/
- https://github.com/ngynLk/polybar-themes
- Animated Polybar Menu:  
  https://www.reddit.com/r/unixporn/comments/92guq6/

---

## Rounded Corners

- https://www.reddit.com/r/unixporn/comments/benebi/
- https://github.com/resloved/i3/pull/3/commits/098c69ec075833597b42891ddbf668f64429d072

---

## Colour Schemes (Pywal)

```bash
pip3 install pywal
wal -i .xlock/background_leaves1.png
wal -R
```

Usage guide:  
https://github.com/dylanaraps/pywal/wiki

---

## Themes

**Nordic GTK Theme**  
https://github.com/EliverLara/Nordic

Install to:
- `/usr/share/themes/`
- `~/.themes/`

### Icons
- https://github.com/EliverLara/Nordic

---

## Xresources

- https://wiki.debian.org/Xresources
- https://i3wm.org/docs/userguide.html#xresources

---

## Redshift

- https://help.ubuntu.com/community/Redshift
- https://askubuntu.com/questions/565963/

---

## i3lock

```bash
i3lock -i wallpaper.png &
```

Convert JPGs to PNG:
```bash
find . -name "*.jpg" -exec mogrify -format png {} \;
```

Scale manually:
```bash
convert -scale 1920x1080 source.png lockscreen.png
```

---

## Prevent Sleep / Hibernation

```bash
xset -dpms
xset s off
```

---

## Media Interaction

List players:
```bash
playerctl -l
```

Control specific player:
```bash
playerctl -p spotify play-pause
```

---

## Terminal Setup (Zsh)

```bash
sudo apt install git wget zsh
zsh --version
chsh -s /bin/zsh
```

Verify:
```bash
echo "$SHELL"
```

### Oh My Zsh
```bash
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
```

### Powerlevel10k
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/themes/powerlevel10k
```

Set in `~/.zshrc`:
```text
ZSH_THEME="powerlevel10k/powerlevel10k"
```

---

## RGB LED Controls (MSI)

https://github.com/nagisa/msi-rgb

```bash
git clone https://github.com/nagisa/msi-rgb
cd msi-rgb
cargo build --release
```

Example:
```bash
sudo ./target/release/msi-rgb FF000000 00FF0000 0000FF00
```

Disable:
```bash
sudo ./target/release/msi-rgb --disable
```

Pulse dim white:
```bash
sudo ./target/release/msi-rgb FEFEFEFE FEFEFEFE FEFEFEFE -p
```

