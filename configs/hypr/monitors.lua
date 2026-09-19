-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- LG ULTRAGEAR 27" 2560x1440 on DP-2: 165Hz max refresh + adaptive sync.
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Primary: LG ULTRAGEAR 27" — run at native 1440p with max 165Hz refresh.
hl.monitor({ output = "DP-2", mode = "2560x1440@164.96Hz", position = "0x0", scale = 1, transform = 0 })

-- Fallback: any other monitor keeps the preferred mode, 1x scale.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Enable adaptive sync (FreeSync/G-Sync Compatible) on Fullscreen only (2 = fullscreen only, prevents desktop stutter)
hl.config({ misc = { vrr = 2 } })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- Auto-injected missing globals (vfr = true enables variable framerate rendering)
hl.config({
    debug = {
        vfr = true,
    },
})
