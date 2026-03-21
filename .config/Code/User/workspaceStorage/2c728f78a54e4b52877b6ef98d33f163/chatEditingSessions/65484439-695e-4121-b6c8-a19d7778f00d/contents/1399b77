#!/usr/bin/env bash
# Wrapper to run commands triggered by swaync buttons with a sane environment
set -euo pipefail

# Ensure common bins are in PATH
PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:$PATH"

# Ensure XDG runtime dir is set for Wayland clients
: "${XDG_RUNTIME_DIR:=/run/user/$(id -u)}"

# Ensure OMARCHY_PATH available
: "${OMARCHY_PATH:=$HOME/.config/omarchy}"

if [ $# -eq 0 ]; then
  echo "Usage: $0 <command...>" >&2
  exit 2
fi

cmd="$*"

# Run the command in a login-compatible shell so $HOME and $PATH expand
exec bash -lc "$cmd"
