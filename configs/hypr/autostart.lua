-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Fcitx5 is already managed by the systemd user service
-- `omarchy-fcitx5.service` (enabled), so we do NOT spawn it again here
-- to avoid a double instance / conflict.
-- hl.exec_cmd("fcitx5 -d")

-- ML4W Quickshell (ported to Omarchy): sidebar, dock, power, wallpaper.
--
-- Launched at TOP LEVEL (not inside hl.on("hyprland.start")) because this user
-- file is require()'d while Hyprland is still bringing up the session: quickshell
-- needs WAYLAND_DISPLAY / the D-Bus session bus to be ready, and launching too
-- early made it exit immediately. The sleep gives the session time to finish.
--
-- This file re-runs on every `hyprctl reload`, so the autostart script carries
-- a duplicate guard (atomic lock + /proc scan): at most ONE shell.qml may run.
-- DISABLED 2026-08-20 (user request): ML4W statusbar/dock
-- hl.exec_cmd("sleep 3 && /home/bap/.local/bin/ml4w-quickshell-autostart.sh &")

-- ML4W Quickshell Overview instance (window overview on SUPER+TAB).
-- Separate quickshell instance; the SUPER+TAB bind (bindings.lua) IPC-calls
-- THIS instance directly (`qs -p ~/.config/quickshell/overview ipc call overview
-- toggle`), so it only works while this instance is up. Same duplicate guard
-- as the shell above.
-- DISABLED 2026-08-20 (user request): ML4W overview/sidebar
-- hl.exec_cmd("sleep 5 && /home/bap/.local/bin/ml4w-quickshell-overview-autostart.sh &")

-- DISABLED 2026-08-20 (user request): hyprpm autostart.
-- Allow hyprpm to load plugins without a permission popup on every startup.
-- hl.permission("/usr/bin/hyprpm", "plugin", "allow")

-- Reload hyprpm plugins once when Hyprland finishes starting (applies plugin
-- config without restarting Hyprland). hyprland.start fires once per session,
-- so this never re-runs on config reload.
 --   hl.on("hyprland.start", function()
 --    hl.exec_cmd("hyprpm reload -n")
 --   end)

-- Random wallpaper rotator (runs detached, cycles every 300s via omarchy theme bg set).
hl.exec_cmd("bash /home/bap/.local/bin/rand-wallpaper.sh >/tmp/rand-wallpaper.log 2>&1 &")

-- Omarchy vendor shell (Quickshell desktop: bar, quick settings, lock screen).
-- Managed by Omarchy defaults (/usr/share/omarchy/default/hypr/autostart.lua),
-- no need to duplicate here.
-- hl.exec_cmd("omarchy-launch-shell")

-- disabled per user request 2026-08-20

-- Auto-lock session on boot with lock-explorer
o.exec_on_start("/home/bap/.local/bin/omarchy-lock-on-boot.sh &")

