source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# disable greeting
set -g fish_greeting

# PATH

# EDITOR
# set -gx EDITOR nvim

# aliases
alias ls="eza --icons"
alias ll="eza -lah --icons --git"
alias la="eza -a --icons"
alias lt="eza --tree --level=2 --icons"

alias cat="bat"
alias grep="rg"

# zoxide
zoxide init fish | source

# fzf keybindings
fzf --fish | source

# starship prompt
starship init fish | source
