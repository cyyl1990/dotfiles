# --- Cấu hình Fish Shell Tối ưu (V2 - Bản mở rộng) ---

# 1. Khởi tạo các cấu hình mặc định (CachyOS)
if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

# 2. Lời chào thân thiện (Greeting) tích hợp Fastfetch
function fish_greeting
    echo -e "\n  (◕‿◕) \e[1;34mChào mừng bạn trở lại, Bap!\e[0m"
    fastfetch
    echo -e "  Gõ \e[1;33mhelp_me\e[0m để xem danh sách lệnh đầy đủ.\n"
end

# 3. Biến môi trường
set -gx EDITOR zeditor
set -gx VISUAL zeditor
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml
set -gx STARSHIP_CACHE ~/.config/starship/cache

# 4. Điều hướng (Navigation)
abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a .... 'cd ../../..'
abbr -a cd.. 'cd ..'

# Tự động liệt kê file khi chuyển thư mục
function _ls_on_cd --on-variable PWD
    eza --icons --group-directories-first
end

# 5. Các phím tắt hữu ích (Abbreviations)
# Hệ thống & Gói
abbr -a update 'paru -Syu'
abbr -a install 'paru -S'
abbr -a remove 'paru -Rns'
abbr -a search 'paru -Ss'
abbr -a cleanup 'paru -Rns (paru -Qdtq)'

# File & Disk
abbr -a df 'duf' # Nếu bạn cài duf, nếu không dùng df -h
abbr -a du 'dust' # Nếu bạn cài dust, nếu không dùng du -sh
abbr -a cp 'cp -iv'
abbr -a mv 'mv -iv'
abbr -a rm 'rm -iv'
abbr -a mkdir 'mkdir -pv'

# Mạng & Tiến trình
abbr -a ps 'procs' # Nếu bạn cài procs, nếu không dùng ps aux
abbr -a top 'btop'
abbr -a myip 'curl ifconfig.me'
abbr -a ports 'sudo lsof -i -P -n | grep LISTEN'

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

# 6. Aliases (Nâng cấp lệnh cũ)
alias ls="eza --icons --group-directories-first"
alias ll="eza -lah --icons --git"
alias la="eza -a --icons"
alias lt="eza --tree --level=2 --icons"
alias cat="bat"
alias grep="rg"
alias weathr="weathr -n --hide-location --metric"

# 7. Menu Hỗ trợ Đầy đủ (Advanced Help Menu)
function help_me
    echo -e "\e[1;34m╭──────────────────────────────────────────────────────────╮\e[0m"
    echo -e "\e[1;34m│\e[0m   \e[1;33m󰞷 MENU HỖ TRỢ NHANH (QUICK HELP)\e[0m                      \e[1;34m│\e[0m"
    echo -e "\e[1;34m╰──────────────────────────────────────────────────────────╯\e[0m"
    
    echo -e "\e[1;32m [Hệ thống & Phần mềm]\e[0m"
    echo "   update      : Cập nhật toàn bộ hệ thống (paru)"
    echo "   install     : Cài đặt gói mới (ví dụ: install kitty)"
    echo "   remove      : Gỡ cài đặt và dọn rác cấu hình"
    echo "   top         : Quản lý tiến trình (btop)"
    echo "   cleanup     : Dọn dẹp các gói mồ côi (orphans)"

    echo -e "\e[1;32m [Quản lý File & Đĩa]\e[0m"
    echo "   ll / la     : Liệt kê chi tiết file (kèm icon/ẩn)"
    echo "   lt          : Xem cây thư mục (Tree view)"
    echo "   df / du     : Kiểm tra dung lượng đĩa/thư mục"
    echo "   z <tên>     : Nhảy nhanh tới thư mục bất kỳ (Zoxide)"

    echo -e "\e[1;32m [Mạng & Kết nối]\e[0m"
    echo "   myip        : Xem địa chỉ IP công cộng của bạn"
    echo "   ports       : Xem các cổng đang mở (LISTEN)"
    echo "   ping <url>  : Kiểm tra kết nối mạng"

    echo -e "\e[1;32m [Script Cá nhân (~/.local/bin)]\e[0m"
    echo "   auto-sort-downloads.sh : Tự động sắp xếp Downloads"
    echo "   backup-all.sh          : Chạy toàn bộ script backup"
    echo "   theme-manager          : Thay đổi giao diện hệ thống"
    echo "   waybar-theme           : Đổi theme cho Waybar"

    echo -e "\e[1;32m [Git & Coding]\e[0m"
    echo "   gs / ga / gc: Phím tắt Git Status/Add/Commit"
    echo "   gp / gl     : Git Push/Pull"
    echo "   zed / z     : Mở trình soạn thảo Zed"

    echo -e "\e[1;33m 💡 Mẹo: Dùng phím 'Tab' để tự động hoàn thành lệnh.\e[0m"
    echo -e "\e[1;34m╰──────────────────────────────────────────────────────────╯\e[0m"
end

# 8. Khởi tạo công cụ
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
