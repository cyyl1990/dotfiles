# --- Cấu hình Fish Shell Tối ưu cho Người mới ---

# 1. Khởi tạo các cấu hình mặc định (CachyOS)
if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

# 2. Lời chào thân thiện (Greeting)
function fish_greeting
    echo -e "\n  (◕‿◕) \e[1;34mChào mừng bạn trở lại, Bap!\e[0m"
    echo -e "  Hôm nay là \e[1;32m$(date +'%A, %d/%m/%Y')\e[0m"
    echo -e "  Gõ \e[1;33mhelp_me\e[0m để xem các lệnh hữu ích.\n"
    # fastfetch --compact
end

# 3. Biến môi trường
set -gx EDITOR zeditor
set -gx VISUAL zeditor
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml
set -gx STARSHIP_CACHE ~/.config/starship/cache

# 4. Điều hướng (Navigation) - Cực kỳ tiện lợi
abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a .... 'cd ../../..'
abbr -a cd.. 'cd ..'

# Tự động liệt kê file khi chuyển thư mục (Tùy chọn)
function _ls_on_cd --on-variable PWD
    eza --icons --group-directories-first
end

# 5. Các phím tắt hữu ích (Abbreviations - Giúp học lệnh nhanh hơn)
# Hệ thống
abbr -a update 'paru -Syu'
abbr -a install 'paru -S'
abbr -a remove 'paru -Rns'
abbr -a search 'paru -Ss'
abbr -a cleanup 'paru -Rns (paru -Qdtq)'

# Git
abbr -a g 'git'
abbr -a gs 'git status'
abbr -a ga 'git add .'
abbr -a gc 'git commit -m'
abbr -a gp 'git push'
abbr -a gl 'git pull'

# Khác
abbr -a cls 'clear'
abbr -a h 'history'
abbr -a q 'exit'
abbr -a z 'zed'

# 6. Aliases (Thay thế lệnh cũ bằng bản nâng cấp)
alias ls="eza --icons --group-directories-first"
alias ll="eza -lah --icons --git"
alias la="eza -a --icons"
alias lt="eza --tree --level=2 --icons"
alias cat="bat"
alias grep="rg"
alias weathr="weathr -n --hide-location --metric"

# 7. Hàm hỗ trợ người mới (Help Menu)
function help_me
    echo -e "\e[1;34m=== Menu Hỗ trợ Nhanh ===\e[0m"
    echo -e "\e[1;32m[Hệ thống]\e[0m"
    echo "  update    : Cập nhật toàn bộ hệ thống"
    echo "  install   : Cài đặt phần mềm mới"
    echo "  remove    : Gỡ cài đặt phần mềm"
    echo "  cls       : Xóa sạch màn hình terminal"
    echo -e "\e[1;32m[Điều hướng]\e[0m"
    echo "  .. , ...  : Lùi về thư mục cha"
    echo "  lt        : Xem cấu trúc thư mục (Tree view)"
    echo "  z <tên>   : Nhảy nhanh tới thư mục (Zoxide)"
    echo -e "\e[1;32m[Git]\e[0m"
    echo "  gs        : Xem trạng thái Git"
    echo "  gp, gl    : Đẩy hoặc kéo code (Push/Pull)"
    echo -e "\e[1;34m=========================\e[0m"
end

# 8. Khởi tạo các công cụ hỗ trợ (Zoxide, Fzf, Starship)
if command -v zoxide > /dev/null
    zoxide init fish | source
end

if command -v fzf > /dev/null
    fzf --fish | source
    set -Ux FZF_DEFAULT_OPTS "--color=bg:#1e1e2e,fg:#cdd6f4,hl:#89b4fa"
end

if command -v starship > /dev/null
    starship init fish | source
end

# 9. Paths
fish_add_path /home/bap/.spicetify
fish_add_path /home/bap/.local/bin
