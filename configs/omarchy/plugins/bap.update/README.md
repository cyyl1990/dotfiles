# Bap Update Sentry

Keep an eye on pacman without leaving your bar.
Every Omarchy user is an Arch user - Bap Update Sentry makes sure a `linux` or `nvidia` bump, a forgotten `.pacnew`, or theme updates never sneak past you.

## Features

- **Bar widget**: pending update count from `checkupdates` + AUR + theme clones (refreshed every 30 minutes, no root needed).
The icon turns urgent when a risky package is in the batch or .pacnew files are waiting.
- **Overlay popup** (click the widget or bind a key):
  - Pending repo updates with risky packages (kernels, nvidia, systemd, grub, mkinitcpio, glibc, mesa, hyprland, ...) sorted first and flagged.
  - AUR updates with risky package detection.
  - Unmerged `.pacnew` / `.pacsave` files under `/etc`.
  - Theme updates for cloned git themes (6h throttle for git fetch).
- Cache state in `~/.cache/bap-update-sentry/` for instant reads.

## Install

Already configured in shell.json bar layout (right section). Just ensure symlink exists:

```bash
bap-suite link bap.update
omarchy-restart-shell
```

Requires `pacman-contrib` (for `checkupdates`), `yay` (for AUR), `curl`, and `python3` - all standard on Omarchy.

## Keybinding (optional)

Add to `~/.config/hypr/bindings.lua`:

```lua
o.bind("SUPER + ALT + P", "Bap Update Sentry", "omarchy-shell shell summon bap.update '{}'")
```

## Keys in the overlay

| Key | Action |
| --- | --- |
| `↑` / `↓`, `j` / `k` | Scroll |
| `r` | Re-check now (full check with network) |
| `u` | Launch system update in terminal |
| `t` | Launch theme update in terminal |
| `Esc` / `q` | Close |

## IPC Commands

```bash
# Get current status
qs ipc -p /usr/share/omarchy/shell call bap.update probe

# Force refresh
qs ipc -p /usr/share/omarchy/shell call bap.update refresh

# Refresh from cache
qs ipc -p /usr/share/omarchy/shell call bap.update refreshCached
```

## Uninstall

```bash
bap-suite disable bap.update
bap-suite unlink bap.update
```

Cache lives in `~/.cache/bap-update-sentry/` and can be deleted freely.

## License

MIT
