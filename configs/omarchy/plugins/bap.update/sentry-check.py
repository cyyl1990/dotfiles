#!/usr/bin/env python3
"""Bap Update Sentry data collector.

Usage: sentry-check.py [full|auto|cached|mark-seen]

  full      - run checkupdates + yay -Qua, scan /etc for .pacnew;
              write state.json to the cache dir and print it (default).
  auto      - full check only if the cache is older than 5 minutes.
  cached    - print the cached state.json instantly (falls back to full).
  mark-seen - (kept for compatibility) no-op, just re-prints state.

Always prints a single JSON object on stdout.
"""

import fcntl
import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path

CACHE = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "bap-update-sentry"
STATE = CACHE / "state.json"
SEEN = CACHE / "news-seen"
THEME_CACHE = CACHE / "theme-state.json"
PLUGIN_CACHE = CACHE / "plugin-state.json"

PLUGINS_DIR = Path(os.environ.get("HOME", str(Path.home()))) / ".config/omarchy/plugins"

# How often to actually `git fetch` the cloned themes. Remote checks are cheap
# but GitHub will rate-limit 65 repos hammered every 30 minutes, and theme
# updates are rare — 30min is plenty; stale data after user update is handled
# by cache-invalidation in the overlay shortcuts.
THEME_CHECK_INTERVAL = 30 * 60
THEME_TIMEOUT = 5

# Same throttle as themes: git fetch every 30min, cached result otherwise.
PLUGIN_CHECK_INTERVAL = 30 * 60
PLUGIN_TIMEOUT = 5

# Packages where a botched update can leave the system unbootable or the
# session unable to start: kernels, nvidia, boot chain, core plumbing.
RISKY = re.compile(
    r"^(linux(-lts|-zen|-hardened|-rt(-lts)?)?|linux-firmware.*|linux-api-headers"
    r"|nvidia.*|systemd.*|grub.*|mkinitcpio.*|limine.*|refind"
    r"|pacman|glibc|mesa.*|egl-wayland|xorg-server.*|hyprland|sddm|plymouth)$"
)


def log_error(msg):
    try:
        CACHE.mkdir(parents=True, exist_ok=True)
        with open(CACHE / "last-error.log", "a") as f:
            f.write("%s %s\n" % (time.strftime("%F %T"), msg))
    except Exception:
        pass


def get_updates():
    """Return a list of repo update dicts, or None when checkupdates failed."""
    # One retry: a transient mirror hiccup shows up as "Cannot fetch updates"
    # and should not flag the whole check as failed.
    p = None
    for attempt in (1, 2):
        try:
            p = subprocess.run(["checkupdates"], capture_output=True, text=True, timeout=180)
        except Exception as e:
            log_error("checkupdates: " + repr(e))
            return None
        if p.returncode in (0, 2):
            break
        log_error("checkupdates attempt %d exit %d: %s" % (attempt, p.returncode, p.stderr.strip()))
        time.sleep(3)
    if p is None:
        return None
    if p.returncode == 2:  # pacman-contrib: exit 2 means "no updates"
        return []
    if p.returncode != 0:
        return None
    out = []
    for line in p.stdout.splitlines():
        parts = line.split()
        if len(parts) >= 4:  # "name oldver -> newver"
            out.append({
                "name": parts[0],
                "old": parts[1],
                "new": parts[3],
                "risky": bool(RISKY.match(parts[0])),
            })
    return out


def get_aur_updates():
    """Return a list of AUR update dicts via `yay -Qua`, or [] on any failure.

    AUR failures must never block the repo check, so we swallow errors and
    just report an empty list (caller can inspect last-error.log).
    """
    try:
        p = subprocess.run(
            ["yay", "-Qua"],
            capture_output=True, text=True, timeout=240,
        )
    except Exception as e:
        log_error("yay -Qua: " + repr(e))
        return []
    if p.returncode not in (0, 1):
        # yay returns 1 when there are no updates; anything else is odd.
        log_error("yay -Qua exit %d: %s" % (p.returncode, p.stderr.strip()))
        return []
    out = []
    for line in p.stdout.splitlines():
        # `yay -Qua` prints lines like:
        #   pkgname oldver -> newver (repo)
        # or sometimes just "pkgname oldver -> newver" without a repo note.
        if "->" not in line:
            continue
        parts = line.split()
        # strip a trailing "(repo)" token if present
        if parts and parts[-1].startswith("(") and parts[-1].endswith(")"):
            parts = parts[:-1]
        if len(parts) >= 4:
            out.append({
                "name": parts[0],
                "old": parts[1],
                "new": parts[3],
                "risky": bool(RISKY.match(parts[0])),
            })
    return out


def get_pacnew():
    files = []
    for pat in ("*.pacnew", "*.pacsave"):
        p = subprocess.run(
            ["find", "/etc", "-name", pat],
            capture_output=True, text=True,
        )
        files += [f for f in p.stdout.splitlines() if f]
    return sorted(files)


def _theme_list():
    """Cloned theme dirs worth checking, via omarchy's own predicate.

    Reuses omarchy-theme-extras so symlinks, worktrees, and hand-copied
    themes are excluded exactly as the updater expects.
    """
    try:
        p = subprocess.run(
            ["/usr/share/omarchy/bin/omarchy-theme-extras"],
            capture_output=True, text=True, timeout=30,
        )
    except Exception as e:
        log_error("theme-extras: " + repr(e))
        return []
    return [line.strip() for line in p.stdout.splitlines() if line.strip()]


def get_theme_updates():
    """Detect cloned themes with new remote commits.

    Never pulls — only fetches and reports how many commits HEAD is behind.
    Respects a 6h throttle so we don't refetch on every 30-min poll; between
    throttled runs it returns the last cached result so the bar stays stable.
    """
    now = int(time.time())
    cached = {}
    try:
        cached = json.loads(THEME_CACHE.read_text())
    except Exception:
        cached = {}

    if now - cached.get("fetchedAt", 0) < THEME_CHECK_INTERVAL:
        return cached.get("themes", [])

    themes = []
    for path in _theme_list():
        try:
            # Lightweight fetch; does not touch the working tree.
            subprocess.run(
                ["git", "-C", path, "fetch", "--quiet"],
                capture_output=True, text=True, timeout=THEME_TIMEOUT,
            )
            up = subprocess.run(
                ["git", "-C", path, "rev-parse", "@{upstream}"],
                capture_output=True, text=True,
            )
            if up.returncode != 0:
                continue  # no upstream tracking branch — nothing to compare
            behind = subprocess.run(
                ["git", "-C", path, "log", "--oneline", "HEAD..@{upstream}"],
                capture_output=True, text=True,
            )
            lines = [l for l in behind.stdout.splitlines() if l.strip()]
            if lines:
                themes.append({
                    "name": os.path.basename(path.rstrip("/")),
                    "count": len(lines),
                })
        except Exception as e:
            log_error("theme fetch %s: %s" % (path, repr(e)))

    themes.sort(key=lambda t: t["name"])
    try:
        THEME_CACHE.write_text(json.dumps({
            "fetchedAt": now,
            "themes": themes,
        }))
    except Exception:
        pass
    return themes


def get_plugin_updates():
    """Detect git-managed plugins with new remote commits.

    Scans `~/.config/omarchy/plugins/*/` for `.git/` directories, fetches
    `origin HEAD`, and counts how many commits the local HEAD is behind.
    Respects a 6h throttle so we don't refetch on every 30-min poll; between
    throttled runs it returns the last cached result so the bar stays stable.
    Never pulls — only fetches and reports.
    """
    now = int(time.time())
    cached = {}
    try:
        cached = json.loads(PLUGIN_CACHE.read_text())
    except Exception:
        cached = {}

    if now - cached.get("fetchedAt", 0) < PLUGIN_CHECK_INTERVAL:
        return cached.get("plugins", [])

    plugins = []
    if not PLUGINS_DIR.is_dir():
        return plugins

    for entry in sorted(PLUGINS_DIR.iterdir()):
        if not entry.is_dir():
            continue
        if not (entry / ".git").is_dir():
            continue  # not git-managed — skip silently
        try:
            subprocess.run(
                ["git", "-C", str(entry), "fetch", "--quiet", "origin", "HEAD"],
                capture_output=True, text=True, timeout=PLUGIN_TIMEOUT,
            )
            fetch = subprocess.run(
                ["git", "-C", str(entry), "rev-parse", "FETCH_HEAD"],
                capture_output=True, text=True,
            )
            head = subprocess.run(
                ["git", "-C", str(entry), "rev-parse", "HEAD"],
                capture_output=True, text=True,
            )
            if fetch.returncode != 0 or head.returncode != 0:
                continue
            fetch_sha = fetch.stdout.strip()
            head_sha = head.stdout.strip()
            if not fetch_sha or not head_sha or fetch_sha == head_sha:
                continue  # up to date, or no commits yet
            # Count commits HEAD is behind FETCH_HEAD.
            log = subprocess.run(
                ["git", "-C", str(entry), "log", "--oneline", "HEAD..FETCH_HEAD"],
                capture_output=True, text=True,
            )
            lines = [l for l in log.stdout.splitlines() if l.strip()]
            if lines:
                # Probe fast-forward viability: if HEAD has commits not in
                # FETCH_HEAD, the working copy diverged and `omarchy plugin
                # update` will refuse to merge. Skip such plugins so the bar
                # count reflects actionable updates only — they remain visible
                # via the `omarchy plugin update` flow itself.
                ff = subprocess.run(
                    ["git", "-C", str(entry), "rev-list", "--left-only",
                     "--count", "HEAD...FETCH_HEAD"],
                    capture_output=True, text=True, timeout=PLUGIN_TIMEOUT,
                )
                if ff.returncode == 0 and ff.stdout.strip().isdigit() and int(ff.stdout.strip()) > 0:
                    log_error("plugin %s diverged (left-only=%s) — skipping" % (entry.name, ff.stdout.strip()))
                    continue
                # Also skip when the working tree is dirty: `omarchy plugin
                # update` validates the merge result and dirty files would
                # collide. Predicate: `git diff --quiet` returns non-zero
                # when there are tracked modifications.
                dirty = subprocess.run(
                    ["git", "-C", str(entry), "diff", "--quiet"],
                    capture_output=True, text=True, timeout=PLUGIN_TIMEOUT,
                )
                if dirty.returncode != 0:
                    log_error("plugin %s working tree dirty — skipping" % entry.name)
                    continue
                plugins.append({
                    "name": entry.name,
                    "count": len(lines),
                })
        except Exception as e:
            log_error("plugin fetch %s: %s" % (entry.name, repr(e)))

    plugins.sort(key=lambda p: p["name"])
    try:
        PLUGIN_CACHE.write_text(json.dumps({
            "fetchedAt": now,
            "plugins": plugins,
        }))
    except Exception:
        pass
    return plugins


def seen_ts():
    try:
        return int(SEEN.read_text().strip())
    except Exception:
        return 0


def write_state(state):
    CACHE.mkdir(parents=True, exist_ok=True)
    tmp = STATE.with_suffix(".tmp")
    tmp.write_text(json.dumps(state))
    tmp.replace(STATE)


def load_state():
    try:
        return json.loads(STATE.read_text())
    except Exception:
        return None


def build():
    # Serialize full checks: concurrent checkupdates/yay runs fight over the
    # sync db lock and one fails, which reads as a bogus "check failed".
    CACHE.mkdir(parents=True, exist_ok=True)
    with open(CACHE / "lock", "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        fresh = load_state()
        if fresh and int(time.time()) - fresh.get("generatedAt", 0) < 30:
            return fresh  # another run just finished while we waited
        return build_locked()


def build_locked():
    prev = load_state() or {}
    updates = get_updates()
    aur = get_aur_updates()
    pacnew = get_pacnew()
    themes = get_theme_updates()
    plugins = get_plugin_updates()
    state = {
        "generatedAt": int(time.time()),
        "updatesError": updates is None,
        "updates": updates if updates is not None else prev.get("updates", []),
        "aur": aur,
        "aurError": False,
        "pacnew": pacnew,
        "themes": themes,
        "plugins": plugins,
    }
    write_state(state)
    return state


def mark_seen():
    # Kept for compatibility; this collector has no news to mark.
    state = load_state() or build()
    write_state(state)
    return state


def invalidate():
    """Clear theme and plugin caches to force fresh re-fetch on next check."""
    for path in (THEME_CACHE, PLUGIN_CACHE):
        try:
            if path.is_file():
                path.unlink()
        except Exception:
            pass
    return load_state() or {}


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "full"
    if mode == "cached":
        state = load_state() or build()
    elif mode == "auto":
        state = load_state()
        if not state or int(time.time()) - state.get("generatedAt", 0) > 300:
            state = build()
    elif mode == "mark-seen":
        state = mark_seen()
    elif mode == "invalidate":
        state = invalidate()
    else:
        state = build()
    print(json.dumps(state))


if __name__ == "__main__":
    main()
