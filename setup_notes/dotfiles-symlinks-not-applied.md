# install.sh / restore_config.sh — Symlinks Silently Not Applied

**Symptom:** Editing a file in `dotfiles/.config/polybar/` (or `.bin/`, `i3/`,
`picom/`, `rofi/`) has no effect on the running system. `~/.config/polybar`
looks like a normal directory, not a symlink into the repo, even though
`restore_config.sh` is supposed to have symlinked it.

Found 2026-08-24 while adding the polybar lid-switch module — edited
`dotfiles/.config/polybar/config_Option5`, restarted polybar, and the new
module never loaded because polybar was reading a completely different,
stale copy of the file at `~/.config/polybar/config_Option5`.

---

## What's supposed to happen

`install.sh` runs `dotfiles/restore_config.sh`, which is meant to:

1. Back up any existing `~/.config/{polybar,i3,picom,rofi}` and `~/.bin`.
2. Replace each of them with a symlink to the matching directory in this repo
   (`dotfiles/.config/polybar` etc.), so live config *is* the repo — edit the
   repo, changes apply immediately (this is the whole point of a dotfiles repo).

## What actually happens

`restore_config.sh`'s `backup_if_exists()` only **copies** the existing
directory into the backup location — it never removes or moves the original:

```bash
backup_if_exists() {
    local target="$1"
    if [ -e "$target" ]; then
        ...
        cp -r "$target" "$backup_dir/${base}.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
    fi
}
```

So when `create_symlink()` then runs `ln -sfn "$src" "$dst"`, `$dst` (e.g.
`~/.config/polybar`) still exists as a **real directory**. `ln -sfn` on an
existing real directory doesn't replace it — it creates the symlink *inside*
it instead, named after `basename("$src")`. The result: a harmless, unused
stray symlink buried one level down —

```
~/.config/polybar/polybar -> ~/projects/linux-setup/dotfiles/.config/polybar
~/.bin/.bin                -> ~/projects/linux-setup/dotfiles/.bin
```

— while `~/.config/polybar` and `~/.bin` themselves stay frozen as whatever
plain copy existed before that run. Confirmed by matching timestamps: both
the stray inner symlinks and `~/.config_backup_20260314_151415/` (the
pre-existing configs `restore_config.sh` copied aside) are dated
`2026-03-14 15:14` — the last time `install.sh`/`restore_config.sh` ran.

Note `install.sh` has its **own**, correct (`mv`-based) `backup_if_exists`/
`create_symlink` pair defined at the top of the file — but it's dead code,
never called. All actual `.config`/`.bin` symlinking is delegated to
`dotfiles/restore_config.sh`'s buggy version instead.

## Fix (not yet applied — confirm before running)

In `dotfiles/restore_config.sh`, change `backup_if_exists()` to actually move
the original out of the way (matching `install.sh`'s unused version), e.g.:

```bash
backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/$(basename "$target").backup.$(date +%Y%m%d_%H%M%S)"
    fi
}
```

Then re-run `restore_config.sh` (or manually swap each live directory for a
symlink after confirming the repo copy has everything the live one does —
diff first, don't blindly overwrite, in case the live copy has drift the repo
never got).

## Until fixed

Any edit to `dotfiles/.config/*` or `dotfiles/.bin/*` needs to be manually
copied to the matching `~/.config/*` / `~/.bin/*` path too, or it silently
won't take effect. Check with:

```bash
diff -r ~/.config/polybar/ ~/projects/linux-setup/dotfiles/.config/polybar/
diff -r ~/.bin/ ~/projects/linux-setup/dotfiles/.bin/
```
