# Bap Notifications

Fork của [njpatel/omapager](https://github.com/njpatel/omapager) — notification daemon cho
Omarchy với grouped notifications, inline actions và screen-sharing detection.

## Fork so với upstream

Plugin này là bản fork cá nhân. Khác biệt với upstream:

- **Tên:** `bap.notification` (thay vì `njpatel.omapager`).
- **Quản lý:** qua `bap-suite` (trong repo `~/Github/bap-plugins-omarchy`), không dùng
  `omarchy plugin add/remove`.
- **Không có bell icon trên bar** (2026-09-18): do architectural limitation của Omarchy shell
  với third-party bar plugins, widget bell không load khi plugin bị disable khỏi service host.
  Toggle DND bằng command thay vì click.

## Cài đặt

Plugin được quản lý qua `bap-suite`:

```bash
bap-suite link bap.notification   # tạo symlink nếu chưa có
bap-suite status                  # xem trạng thái
```

Plugin nằm trong `bar.layout.center` của `~/.config/omarchy/shell.json`. Bell icon
không hiển thị — xem mục DND toggle bên dưới.

## DND toggle (command)

```bash
omarchy-shell omapager dnd        # toggle Do Not Disturb
omarchy-shell omapager probe      # xem trạng thái JSON (doNotDisturb, toasts, …)
omarchy-shell omapager snoozeAll 60  # tắt notification 60 phút
omarchy-shell omapager clear      # xóa notification trên màn hình
```

## IPC commands đầy đủ

| Command | Mô tả |
|---|---|
| `omarchy-shell omapager count` | Số notification đang hiện |
| `omarchy-shell omapager clear` | Dismiss tất cả |
| `omarchy-shell omapager dnd` | Toggle Do Not Disturb |
| `omarchy-shell omapager expand` | Mở notification panel |
| `omarchy-shell omapager snooze 30` | Snooze notification đầu 30 phút |
| `omarchy-shell omapager snoozeAll 60` | Snooze tất cả 60 phút |
| `omarchy-shell omapager probe` | Xem JSON trạng thái |
| `omarchy-shell omapager.panel toggle` | Mở/đóng notification panel |

## Keybinding gợi ý

Thêm vào `~/.config/hypr/bindings.lua`:

```lua
-- Toggle DND
bind = "SUPER", "D", "exec", "omarchy-shell omapager dnd"
```

## Credit

- **Upstream:** [njpatel/omapager](https://github.com/njpatel/omapager) — Neil Patel, Apache-2.0.
- **Fork:** Bắp (bap).

## Cách sửa

```bash
bap-suite check bap.notification   # kiểm cú pháp trước
# sửa file trong bap.notification/
omarchy restart shell
bap-suite log bap.notification    # xem lỗi runtime
```

## State

State nằm ở `~/.local/state/omarchy/omapager/`. Xóa thủ công nếu muốn reset.
