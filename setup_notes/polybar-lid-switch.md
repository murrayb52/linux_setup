# Polybar Lid-Sleep Toggle

**What:** A "lid" module next to the power button (Option5 bottom bar) that lets
you flip between the default behaviour (lid close suspends) and staying awake
with the lid closed, via a two-choice popup — the same `custom/menu` mechanism
as the power button.

**Files:**
- `dotfiles/.config/polybar/config_Option5` — `[module/lid]` section, and
  `lid` added to `modules-right` on `[bar/bottom]`.
- `dotfiles/.bin/scripts/lid-mode.sh` — does the actual toggle. Fully commented;
  `lid-mode.sh {sleep|awake|status}`.

---

## Why root is needed, and the sudoers step a plain `install.sh` run will miss

Toggling the setting masks/unmasks four systemd targets
(`sleep.target suspend.target hibernate.target hybrid-sleep.target`) — masking
them makes lid-close (and `systemctl suspend`) a no-op system-wide, regardless
of `/etc/systemd/logind.conf`. That requires root, and a polybar click has no
terminal to type a password into.

**This is set up via a sudoers rule that lives outside the repo**, at
`/etc/sudoers.d/lid-mode`, scoped to exactly the two commands the script needs:

```
muzz ALL=(root) NOPASSWD: /usr/bin/systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target, /usr/bin/systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

`install.sh` / `restore_config.sh` do not create this file — a fresh machine
restore will symlink the polybar config and the script, but clicking the lid
button will just hang/fail with a sudo password prompt polybar can't show
until this is added by hand:

```bash
cat <<'EOF' | sudo tee /etc/sudoers.d/lid-mode
muzz ALL=(root) NOPASSWD: /usr/bin/systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target, /usr/bin/systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
EOF
sudo chmod 0440 /etc/sudoers.d/lid-mode
sudo visudo -c   # validate syntax before trusting it
```

## Verifying it's wired up correctly

```bash
# Should print "static" for all four (unmasked / default) — "masked" means awake mode
systemctl list-unit-files | grep -E "sleep\.target|suspend\.target|hibernate\.target|hybrid-sleep\.target"

# Should run with no password prompt if the sudoers rule is in place
sudo -n /usr/bin/systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target && echo OK
sudo -n /usr/bin/systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target && echo OK

~/.bin/scripts/lid-mode.sh status   # sleep | awake
```

See [[dotfiles-symlinks-not-applied]] for why editing files in this repo may
not be enough on its own — check that `~/.config/polybar` and `~/.bin` are
actually symlinks into the repo before assuming a config edit took effect.
