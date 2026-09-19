local paths = require("default.hypr.paths")
local require_optional = require("default.hypr.require_optional")

-- GUM environment variables for styling purposes.
require_optional.module("omarchy.current.theme.gum_env")

-- Cursor theme & size (Bibata, 24px).

-- Force all apps to use Wayland.
-- Moved to ~/.config/environment.d/wayland-apps.conf (managed by systemd/UWSM)

-- Allow better support for screen sharing (Google Meet, Discord, etc).
-- XDG session vars (DESKTOP_SESSION, XDG_CURRENT_DESKTOP, etc) are automatically set by UWSM.
-- XDG_SESSION_CLASS is set in ~/.config/environment.d/session.conf

-- Appearance / cursor
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("GTK_USE_PORTAL", "1") -- use xdg-desktop-portal file picker on Hyprland
hl.env("QT_QUICK_CONTROLS_NATIVE_DIALOGS", "0") -- keep Qt Quick dialogs non-native; the gtk3 theme's native file picker crashes the shell


-- Fcitx5
-- Moved to ~/.config/environment.d/fcitx5.conf

-- Use XCompose file.
hl.env("XCOMPOSEFILE", paths.home .. "/.XCompose")

-- hyprctl setenv doesn't reach keybind dispatcher env; use hl.env.
hl.env("OMARCHY_PATH", paths.omarchy_path)

local bin_dir = paths.omarchy_path .. "/bin"
local kept = {}
for entry in (os.getenv("PATH") or "/usr/local/bin:/usr/bin"):gmatch("[^:]+") do
  if entry ~= bin_dir then table.insert(kept, entry) end
end
table.insert(kept, 1, bin_dir)
hl.env("PATH", table.concat(kept, ":"))

-- Hardware-specific environment.
require("default.hypr.nvidia")
-- NVIDIA variables (LIBVA_DRIVER_NAME, NVD_BACKEND, etc) are moved to ~/.config/environment.d/nvidia-vaapi.conf

hl.config({
  xwayland = {
    force_zero_scaling = true,
  },

  ecosystem = {
    no_update_news = true,
  },
})
