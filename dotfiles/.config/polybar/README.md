# Polybar

One config, [`config.ini`](config.ini), with two bars: `main` along the top and
`bottom` along the bottom. Translucent black with green accents.

`~/.config/polybar` is a symlink to this folder (set up by
`dotfiles/restore_config.sh`), so edits here are live once polybar restarts.

## Bars

| Bar | Left | Centre | Right |
|---|---|---|---|
| `main` (top) | flockr workspaces, i3 binding mode | date and time | Claude usage, Wi-Fi, Bluetooth, mail, LocalSend |
| `bottom` | CPU, free memory, free disk, local IP | | volume, battery, lid switch, power menu |

- **flockr**: workspaces with each agent's status (`!` needs you, `✓` done, spinner working, `○` idle). Needs [flockr](https://github.com/murrayb52/flockr) on `PATH`.
- **Claude usage**: the 5-hour or 7-day usage gauge, only shown while a Claude Code agent is running. Click to switch.
- **Lid switch**: choose whether closing the lid suspends. See `~/.bin/scripts/lid-mode.sh`.
- **Power menu**: power off, reboot, log out, switch user and lock. Lock runs `loginctl lock-session`, so it's the same blurred lock as Super+Shift+L.

## Launching

[`launch.sh`](launch.sh) kills any running bars, then starts `main` and
`bottom` on every connected monitor, primary first. It runs from the i3 config
(`exec_always`, so on every i3 reload) and from autorandr's
`postswitch.d/refresh-desktop` hook when monitors change.

To apply an edit, reload i3 (`$mod+Shift+r`) or run:

```shell
~/.config/polybar/launch.sh
```

If a bar doesn't appear, run it in a terminal to see polybar's errors:

```shell
MONITOR=eDP-1 polybar -c ~/.config/polybar/config.ini main
```

## Scripts

| Script | Used by | What it does |
|---|---|---|
| `launch.sh` | i3, autorandr | Starts the bars (above) |
| `i3-mode.sh` | `i3-mode` | Shows the current i3 binding mode (e.g. resize), blinking; hidden otherwise |
| `claude-usage.sh` | `claude-usage` | Claude subscription usage from Claude Code's OAuth token (`curl`, `jq`) |
| `wifi-status.sh` | `wifi-module` | Wi-Fi state icon (`nmcli`) |
| `wifi-menu.sh` | `wifi-module` click | Opens `nmtui` in a floating terminal |
| `bluetooth-status.sh` | `bluetooth-module` | Bluetooth state icon (`bluetoothctl`) |
| `bluetooth-menu.sh` | `bluetooth-module` click | Opens `blueman-manager`, floating |
| `tuta-mail.sh` | `mail-module` click | Opens Tuta Mail, floating |
| `localsend.sh` | `localsend-module` click | Opens LocalSend, floating |

The floating windows are set up by `for_window` rules in the i3 config.

## Fonts

| Font | Used for |
|---|---|
| FontAwesome (4) | Most icons |
| Hack | Bar text |
| Hack Nerd Font | Wi-Fi and Bluetooth state icons (FontAwesome 4 has no on/off/connected variants) |
| DejaVu Sans | flockr's status glyphs |
