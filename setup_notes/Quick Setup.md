# Setting up a new Linux enviroment

## 1. Clone repo

1. Generate ssh key
```shell
sudo apt install openssh-server
ssh-keygen
```
2. Print and copy contents of SSH key: 
```shell
$ cat ~/.ssh/id_ed25519.pub
```
3. Register SSH key on GitHub through [GitHub Settings > Keys](https://github.com/settings/keys). More details: [Adding a new SSH key to your account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account#adding-a-new-ssh-key-to-your-account)

4. Clone repo with ssh key: git@github.com:murrayb52/linux_setup.git
```shell
$ mkdir ~/project
$ cd ~/projects
$ git clone git@github.com:murrayb52/linux_setup.git
```

### Previous Issues
If you can't clone to projects as with the below error, ensure `~/projects` is owned by the same user that you generated ssh keys for. If you accidentally create `~/projects` with root user (via sudo), you will have to change the folder ownership or generate and register ssh keys for the root user. Rather fix the folder ownership as below:

```shell
murray@murray-work-ubuntu:~/projects $ git clone git@github.com:murrayb52/linux_setup.git
fatal: could not create work tree dir 'linux_setup': Permission denied

$ sudo chown -R murray:murray ~/projects

$ git clone git@github.com:murrayb52/linux_setup.git
Cloning into 'linux_setup'...
Enter passphrase for key '/home/murray/.ssh/id_ed25519': 
remote: Enumerating objects: 730, done.
remote: Counting objects: 100% (387/387), done.
remote: Compressing objects: 100% (183/183), done.
remote: Total 730 (delta 182), reused 380 (delta 179), pack-reused 343 (from 1)
Receiving objects: 100% (730/730), 58.88 MiB | 7.35 MiB/s, done.
Resolving deltas: 100% (324/324), done.
```

Success!

## 2. (Optional) Setup Obsidian Vault

### Overview
An Obsidian Vault is used for recording learnt Linux knowledge that is often needed. The minimal notes needed for installing and configuring a new Linux are tracked in the git repo: https://github.com/murrayb52/linux_setup but are designed to symlink to the Obsidian Vault.

This doc explains how to quickly install and restore the ObsidianVault from a synced device using SyncThing.

### 1) Install Obsidian
Download the latest Obsidian .deb package from [https://obsidian.md/download](https://obsidian.md/download)

Install the package:
```shell
cd ~/Downloads
sudo dkpg -i obsidian_X.XX.X_amd64.deb
```

### 2) Install Syncthing (Linux desktop)

```shell
sudo apt update
sudo apt install syncthing
```

Start & enable the user service (recommended):

```shell
# enable lingering if you want syncthing to run when not logged-in
sudo loginctl enable-linger $USER

# enable and start the systemd user service
systemctl --user enable syncthing.service
systemctl --user start syncthing.service
```

Access the web GUI at: http://127.0.0.1:8384/ (open in your browser). The first run will generate a device ID and an API key.

### 3) Basic pairing (desktop ↔ phone)

Note: this step assume the device you are syncing to already has the Obsidian Vault. If not, you will need to create the vault and the corresponding folder ID on SyncThing.
- From new device: "Actions → Show ID"
- From existing device: "Add Device", scan the barcode. Alternatively copy the Device ID to the new device, and give it name.
- Select folder to sync using checkbox for *ObsidianVault*.
- Enable *"Auto Accept"*
- Complete device setup.

### 4) Obsidian + Git Repo Integration (Symlinked Notes)

The vault's *Linux/Setup* folder is designed to symlink to the *Obsidian Vault > Linux > Setup* folder in the `linux_setup` [git repo](https://github.com/murrayb52/linux_setup) so that crucial setup notes are available when setting up a new linux install with this repo.  The result is a single Obsidian vault with minimal notes managed by git.

Create the symlink

```bash
ln -s ~/projects/linux-setup/setup-notes \
      ~/ObsidianVault/Linux/Setup
```

Check the symlink worked:
![[Pasted image 20260304120239.png]]

![[Pasted image 20260304120423.png]]

You can now navigate the setup notes directly from Obsidian!

### (Additional) More SyncThing settings for Obsidian Vault
#### Ignore patterns for Obsidian Valuts (.stignore)

Add an ignore file in the folder options or in the Syncthing GUI to avoid syncing transient or local-only files. Example ignores:

```
.obsidian/workspace
.obsidian/local/*
cache
*.tmp
index.lock
```

#### Conflict handling and tips

- Syncthing will create conflict files named like `file (sync-conflict-YYYYMMDD-HHMMSS).ext` when changes happen on both devices. Merge manually in Obsidian when that occurs.
- Use versioning (see folder settings) to recover previous file states.
- Avoid editing the same note simultaneously on both devices if possible.

#### Security & remote access

- By default the Syncthing GUI listens only on localhost. If you need to access it remotely, use an SSH tunnel or secure reverse proxy.
- Keep Device IDs private and only approve devices you control.

### References & further reading
- Syncthing official: https://syncthing.net/
- Syncthing Android (F-Droid / Play Store)
---

## 3. Setup i3

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

### Favourite Packages
[TLDR](https://tldr.sh/): quick summaries of man pages
### Restore Existing System

- Restore dotfiles from GitHub:  
  https://github.com/addy-dclxvi/dotfiles

---

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

