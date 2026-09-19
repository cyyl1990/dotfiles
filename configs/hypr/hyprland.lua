-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.envs")
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")
require("hypr.windows")
require("hypr.rules")
require("hypr.permission")
require("hypr.source.workspace_rules")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Default layout for all workspaces = dwindle (set globally in looknfeel.lua).
-- No per-workspace master override — the workspace-layout-toggle is free to switch.

-- Gloview plugin (installed via hyprpm, enabled: true)
--[[
-- hl.config({
    plugin = {
        gloview = {
            layout         = "rows",
            gap            = 34,
            padding        = 80,
            padding_top    = 40,
            padding_bottom = 70,
            max_scale      = 1.0,
            duration       = 200,
            preview_round  = 12,
            blur           = 1,

            switch_animation = 1,
            switch_duration  = 260,
            move_animation   = 1,
            move_duration    = 240,

            anchor           = "top",
            strip_offset     = 0,
            strip_height     = 150,
            strip_margin     = 22,
            strip_gap        = 18,
            strip_card_round = 10,

            focus_follows_mouse       = 1,
            scroll_switches_workspace = 1,
            passthrough_keys          = 1,
            exit_on_click             = 1,
            exit_on_switch            = 0,

            key_close     = "escape",
            key_next_workspace = "tab",
            key_prev_workspace = "shift+tab",
            key_activate  = "enter",
            key_close_window = "d",
            key_left      = "left",
            key_right     = "right",
            key_up        = "up",
            key_down      = "down",
            key_desktop   = "shift",
            key_all_workspaces = "a",
            key_workspace = "1,2,3,4,5,6,7,8,9,0",

            show_all_workspaces     = 0,
            show_empty              = 1,
            dynamic_workspaces      = 1,
            autodelete_empty        = 1,
            show_workspace_labels   = 1,
            show_window_labels      = 1,
            show_special            = 0,
            strip_all_card          = 1,
            drag_to_swap            = 1,
            switch_on_drop          = 0,
            switch_on_new_workspace = 1,

            hide_top_layers     = 0,
            hide_overlay_layers = 0,
            above_namespaces    = "",
            debug_logs = 0,

            select_border_size  = 3,
            select_border       = 0xf066ccff,
            close_button_color  = 0xe6e23b3b,
            backdrop_color      = 0x73070a10,
            strip_band_color    = 0x24ffffff,
            strip_card_color    = 0x3a0e131c,
            strip_active_color  = 0x4d1c2c44,
            strip_active_border = 0xf0ffffff,
            strip_hover_border  = 0x80ffffff,
            strip_active_border_size = 2,
            strip_hover_border_size  = 2,
            strip_plus_color    = 0xd0eef4ff,
            preview_bg          = 0xff14181f,
            shadow_color        = 0x70000000,
            hover_border        = 0xf0ffffff,
            hover_border_size   = 3,
        },
    },
 })
]]

-- Load settings written by OmaSettings (omasettings:managed).
require("hypr.omasettings")





-- wmfeht.border-fx (Omarchy plugin control plane; pcall if the file is missing)
pcall(require, "hypr.border-fx")

-- Qutebrowser window rules: match terminal 0.90 transparency
o.window("([oO]rg\\.[qQ]utebrowser\\.[qQ]utebrowser|[qQ]utebrowser)", {
  tag = "-default-opacity",
  opacity = "0.90 0.85",
})
