#!/bin/bash

# --- Script Cài đặt Tự động Dotfiles (Dành cho Arch/CachyOS) ---

set -e

# Màu sắc hiển thị
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Bắt đầu cài đặt Dotfiles ===${NC}"

# 1. Kiểm tra Package Manager
if ! command -v pacman &> /dev/null; then
    echo "Lỗi: Script này chỉ hỗ trợ các distro dựa trên Arch (pacman)."
    exit 1
fi

# 2. Cài đặt các gói phụ thuộc cơ bản
echo -e "${YELLOW}Đang cài đặt các gói phụ thuộc từ kho chính...${NC}"
PKGS=(
    hyprland waybar swaync kitty ghostty alacritty fish starship fastfetch btop cava 
    fcitx5 fcitx5-unikey thunar thunar-archive-plugin gvfs mako 
    qt5ct qt6ct nwg-look neovim tmux git lazygit micro
)

sudo pacman -S --needed --noconfirm "${PKGS[@]}"

# 3. Cài đặt AUR Helper (paru) nếu chưa có
if ! command -v paru &> /dev/null && ! command -v yay &> /dev/null; then
    echo -e "${YELLOW}Đang cài đặt paru (AUR helper)...${NC}"
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru && makepkg -si --noconfirm
    cd -
fi

# 4. Cài đặt các gói từ AUR
echo -e "${YELLOW}Đang cài đặt các gói từ AUR...${NC}"
AUR_HELPER=$(command -v paru || command -v yay)
AUR_PKGS=(
    uwsm pyprland swayosd-git nwg-dock-hyprland walker-bin
    spicetify-cli mangohud vkbasalt easyeffects
)
$AUR_HELPER -S --needed --noconfirm "${AUR_PKGS[@]}"

# 5. Backup config cũ và áp dụng config mới
echo -e "${YELLOW}Đang áp dụng cấu hình dotfiles...${NC}"
DOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

mkdir -p "$CONFIG_DIR"

# Danh sách các thư mục cần copy
for dir in $(ls -A "$DOT_DIR/.config/"); do
    if [ -d "$CONFIG_DIR/$dir" ]; then
        echo "Đang backup $dir hiện có..."
        mv "$CONFIG_DIR/$dir" "$CONFIG_DIR/${dir}_bak_$(date +%Y%m%d)"
    fi
    cp -r "$DOT_DIR/.config/$dir" "$CONFIG_DIR/"
    echo -e "${GREEN}Đã áp dụng config cho: $dir${NC}"
done

# Copy các file ở Home (.zshrc, .bashrc, .profile)
for file in .bashrc .zshrc .profile; do
    if [ -f "$DOT_DIR/$file" ]; then
        [ -f "$HOME/$file" ] && mv "$HOME/$file" "$HOME/${file}_bak"
        cp "$DOT_DIR/$file" "$HOME/"
        echo -e "${GREEN}Đã áp dụng file: $file${NC}"
    fi
done

echo -e "${BLUE}=== Cài đặt hoàn tất! Vui lòng khởi động lại Hyprland. ===${NC}"
