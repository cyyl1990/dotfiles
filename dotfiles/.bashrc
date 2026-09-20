# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap
source "$OMARCHY_PATH/default/bash/rc"

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

. "$HOME/.local/bin/omarchy-env"

# Show a random Pokedex entry on terminal open (interactive terminal only)
if [[ -t 1 ]] && command -v pokedex-greeting >/dev/null 2>&1; then
  pokedex-greeting
fi

# Trợ lý AI mặc định (Google Antigravity CLI)
export AI_AGENT="agy"
export DEFAULT_AI="agy"
alias ai="agy"
alias antigravity-cli="agy"
alias agy-danger="agy --dangerously-skip-permissions"
