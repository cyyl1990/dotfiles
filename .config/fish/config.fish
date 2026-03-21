 source /usr/share/cachyos-fish-config/cachyos-config.fish

set -e FZF__DEFAULT_OPTS
# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# disable greeting
set -g fish_greeting

# PATH

# EDITOR
 set -gx EDITOR zeditor
 set -gx VISUAL zeditor

# aliases
alias ls="eza --icons"
alias ll="eza -lah --icons --git"
alias la="eza -a --icons"
alias lt="eza --tree --level=2 --icons"

alias paruf="paru -Slq | fzf --multi --preview 'paru -Sii {1}' --preview-window=down:75% | xargs -ro paru -S"

alias cat="bat"
alias grep="rg"
alias weathr="weathr -n --hide-location --metric"
alias zed="zeditor"
# zoxide
zoxide init fish | source

# fzf keybindings
fzf --fish | source

# starship prompt
starship init fish | source
set -x STARSHIP_CONFIG ~/.config/starship/starship.toml
set -x STARSHIP_CACHE ~/.config/starship/cache

set -Ux FZF_DEFAULT_OPTS "--color=bg:#1e1e2e,fg:#cdd6f4,hl:#89b4fa"

fish_add_path /home/bap/.spicetify
