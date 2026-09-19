#!/usr/bin/env python3
"""
Auto-switch fcitx5 to US keyboard when focusing a terminal.

Problem: when typing Vietnamese (unikey) and you focus a terminal, you keep
composing Vietnamese diacritics inside the shell, which is annoying.

Solution: poll the active Hyprland window; if its class is a known terminal
emulator, switch fcitx5 to `keyboard-us` (only if not already us). When you
leave the terminal we leave the IM as-is (no surprise switch back).

Runs as a systemd --user service so it survives reboots (see
~/.config/systemd/user/fcitx-auto-us.service).
"""
import json
import subprocess
import time

TERMINAL_CLASSES = {
    "kitty", "dropdown", "alacritty", "ghostty",
    "wezterm", "foot", "st", "urxvt",
}

# Các ứng dụng CLI / Agent cần gõ tiếng Việt tự nhiên (không tự ép về US)
AGENT_CLASSES = {"org.omarchy.agent"}
AGENT_TITLE_KEYWORDS = {"agy", "antigravity", "hermes", "claude", "chat", "gemini"}

US_IM = "keyboard-us"
VI_IM = "lotus"
POLL_INTERVAL = 0.3


def active_window_info() -> tuple[str, str]:
    try:
        out = subprocess.check_output(
            ["hyprctl", "-j", "activewindow"],
            stderr=subprocess.DEVNULL,
            timeout=2,
        ).decode()
        data = json.loads(out)
        cls = (data.get("class") or "").lower()
        title = (data.get("title") or "").lower()
        return cls, title
    except Exception:
        return "", ""


def current_im() -> str:
    try:
        return subprocess.check_output(
            ["fcitx5-remote", "-n"],
            stderr=subprocess.DEVNULL,
            timeout=2,
        ).decode().strip()
    except Exception:
        return ""


def set_im(im: str) -> None:
    try:
        subprocess.run(
            ["fcitx5-remote", "-s", im],
            stderr=subprocess.DEVNULL,
            timeout=2,
        )
    except Exception:
        pass


def is_agent_or_chat(cls: str, title: str) -> bool:
    if cls in AGENT_CLASSES:
        return True
    return any(kw in title for kw in AGENT_TITLE_KEYWORDS)


def main() -> None:
    last_window = None
    while True:
        cls, title = active_window_info()
        current_window = (cls, title)
        if current_window != last_window:
            last_window = current_window
            # Chỉ tự động đổi về US nếu là terminal gõ lệnh thông thường,
            # KHÔNG đổi nếu là agent chat / CLI như Antigravity (agy), Hermes, Claude
            if cls in TERMINAL_CLASSES and not is_agent_or_chat(cls, title):
                if current_im() != US_IM:
                    set_im(US_IM)
            # Rời khỏi terminal: giữ nguyên trạng thái, không tự đổi ngược lại
        time.sleep(POLL_INTERVAL)


if __name__ == "__main__":
    main()
