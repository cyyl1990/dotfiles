#!/usr/bin/env bash
# =============================================================================
# dusky_appearance.sh — launcher for the Dusky Appearance TUI
# Target: patches ~/.config/hypr/looknfeel.lua (Omarchy appearance config)
#
# This wrapper exists because the TUI requires Python 3.12+ WITH the
# 'textual' package. The default 'python3' on this machine is 3.11 (no textual),
# and a user shell may resolve 'python3.14' to a build without textual.
# We therefore pick an explicit interpreter that is known to work.
# =============================================================================

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEMA="$SCRIPT_DIR/tui_appearance.py"
MAIN="$HOME/dusky/user_scripts/dusky_tui/python/main/main.py"

# Preferred interpreters, in order. /usr/bin/python3.14 is verified working.
for PY in /usr/bin/python3.14 python3.14 python3.12; do
    if command -v "$PY" >/dev/null 2>&1; then
        if "$PY" -c "import textual" >/dev/null 2>&1; then
            exec "$PY" "$MAIN" "$SCHEMA" "$@"
        fi
    fi
done

echo "[-] No suitable Python (3.12+ with 'textual') found." >&2
echo "    Install textual:  /usr/bin/python3.14 -m pip install textual" >&2
exit 1
