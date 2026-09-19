#!/usr/bin/env bash
# Launcher for the BAP Control Center (trimmed Dusky Control Center).
# Reads ~/.config/hypr/scripts/omarchy_quattro_config.toml via SCRIPT_DIR.
# Launched DIRECTLY (no terminal wrapper) — the GTK window is the only window.
set -u

SCRIPT="$HOME/.config/hypr/scripts/bap-cc/dusky_control_center_quattro.py"

for PY in /usr/bin/python3.14 python3.14 python3.12; do
    if command -v "$PY" >/dev/null 2>&1; then
        if "$PY" -c "import gi; gi.require_version('Adw','1'); from gi.repository import Adw" >/dev/null 2>&1; then
            exec "$PY" "$SCRIPT" "$@"
        fi
    fi
done

echo "[-] Need Python 3.14+ with PyGObject (GTK4/Adw)." >&2
exit 1
