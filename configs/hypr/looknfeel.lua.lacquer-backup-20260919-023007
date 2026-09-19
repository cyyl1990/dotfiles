-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
    -- ==========================================
    -- GENERAL (Borders, Gaps, Colors)
    -- ==========================================
    general = {
        -- border_size = 2, -- (nhường theme) Size of the border around windows
        -- gaps_in = 6, -- (nhường theme) Gaps between windows
        -- gaps_out = 6, -- (nhường theme) Gaps between windows and monitor edges
        float_gaps = 2, -- Gaps for floating windows (-1 means default)
        gaps_workspaces = 50, -- Gaps between workspaces (stacks with gaps_out)

        -- ["col.inactive_border"] = inverse_on_surface, -- (nhường theme) Border color for inactive windows
        -- ["col.active_border"] = primary, -- (nhường theme) Border color for the active window
        -- ["col.nogroup_border"] = inverse_on_surface, -- (nhường theme) Inactive border color for window that cannot be added to a group
        -- ["col.nogroup_border_active"] = secondary, -- (nhường theme) Active border color for window that cannot be added to a group

        resize_on_border = true, -- Enables resizing windows by clicking and dragging on borders and gaps
        extend_border_grab_area = 15, -- Extends click/drag area around the border (needs resize_on_border)
        hover_icon_on_border = true, -- Shows cursor icon when hovering over borders (needs resize_on_border)
        allow_tearing = true, -- Master switch for allowing tearing to occur
        resize_corner = 0 -- Forces floating windows to use specific corner when resized (1-4, 0 to disable)
    },

    -- ==========================================
    -- DECORATION (Rounding, Blur, Shadows)
    -- ==========================================
    decoration = {
        -- rounding = 12, -- (nhường theme) Rounded corners' radius (in layout px)
        -- rounding_power = 4.0, -- (nhường theme) Curve used for rounding
         active_opacity = 1.0, -- (nhường theme) Opacity of active windows [0.0 - 1.0]
         inactive_opacity = 1.0, -- (nhường theme) Opacity of inactive windows [0.0 - 1.0]
        -- fullscreen_opacity = 1.0, -- (nhường theme) Opacity of fullscreen windows [0.0 - 1.0]
       -- dim_modal = true, -- (nhường theme) Enables dimming of parents of modal windows
        -- dim_inactive = true, -- (nhường theme) Enables dimming of inactive windows
        -- dim_strength = 0.2, -- (nhường theme) How much inactive windows should be dimmed [0.0 - 1.0]
        -- dim_special = 0.7, -- (nhường theme) How much to dim screen when special workspace is open [0.0 - 1.0]
        -- dim_around = 0.4, -- (nhường theme) How much the dim_around window rule should dim by [0.0 - 1.0]
        -- screen_shader = "", -- (nhường theme) Path to custom shader applied at the end of rendering
        -- border_part_of_window = true, -- (nhường theme) Whether the window border should be a part of the window

        -- blur = {
         --    enabled = true, -- (nhường theme) Master switch for window blur
            -- size = 3,       -- (nhường theme) Blur strength (0 - 20)
            -- passes = 4,     -- (nhường theme) Number of blur passes (0 - 5)
            -- noise = 0.02,   -- (nhường theme) Noise applied to the blur [0.0 - 1.0]
            -- contrast = 0.85, -- (nhường theme) Contrast applied to the blur [0.0 - 2.0]
            -- brightness = 0.3, -- (nhường theme) Brightness applied to the blur [0.0 - 2.0]
            -- vibrancy = 0.06, -- (nhường theme) Saturation applied to the blur [0.0 - 2.0]
            -- vibrancy_darkness = 0.70, -- (nhường theme) Saturation applied to dark parts of the blur [0.0 - 2.0]
            -- ignore_opacity = true, -- (nhường theme) Whether to ignore opacity of the window when blurring
            -- new_optimizations = true, -- (nhường theme) Whether to use the new optimizations
            -- xray = false, -- (nhường theme) Whether to avoid blurring behind fully opaque pixels
            -- special = false, -- (nhường theme) Whether to blur behind special workspace (expensive)
            -- popups = false, -- (nhường theme) Whether to blur popups (e.g. right-click menus)
            -- popups_ignorealpha = 0.2, -- (nhường theme) If pixel opacity is below this, will not blur popups [0.0 - 1.0]
            -- input_methods = false, -- (nhường theme) Whether to blur input methods (e.g. fcitx5)
            -- input_methods_ignorealpha = 0.2 -- (nhường theme) If pixel opacity is below this, will not blur input methods [0.0 - 1.0]
            -- },

        -- shadow = {  (nhường theme)
        --     enabled = true, -- Enable drop shadows on windows
        --     range =25, -- Shadow range ("size") in layout px
        --     render_power = 3, -- Falloff power (more power = faster falloff) [1 - 4]
        --     sharp = false, -- Make shadows sharp, akin to infinite render power
        --     color = "rgba(00000066)", -- Shadow's color. Alpha dictates opacity
        --     offset = {0, 6}, -- Shadow's rendering offset
        --     scale = 1.0 -- Shadow's scale [0.0 - 1.0]
        -- },

        glow = {
            enabled = false, -- Enable inner glow on windows
            range = 10, -- Glow range ("size") in layout px
            render_power = 3, -- Falloff power [1 - 4]
            -- color = primary_container -- (nhường theme) Glow's color. Alpha dictates opacity
        }
    },

    -- ==========================================
    -- ANIMATIONS
    -- ==========================================
    animations = {
        workspace_wraparound = false -- Directional workspace animations animate as if first/last are adjacent
    },

    -- ==========================================
    group = {
        -- ["col.border_active"] = primary, -- (nhường theme) Active group border color
        -- ["col.border_inactive"] = inverse_on_surface, -- (nhường theme) Inactive group border color
        -- ["col.border_locked_active"] = tertiary, -- (nhường theme) Active locked group border color
        -- ["col.border_locked_inactive"] = tertiary_container, -- (nhường theme) Inactive locked group border color

        groupbar = {
            -- enabled = true, -- (nhường theme) Enables groupbars
            -- font_family = "", -- (nhường theme) Font for groupbar titles (falls back to misc.font_family)
            -- font_size = 8, -- (nhường theme) Font size of title
            -- font_weight_active = "normal", -- (nhường theme) Font weight of active title
            -- font_weight_inactive = "normal", -- (nhường theme) Font weight of inactive title
            -- gradients = false, -- (nhường theme) Enables gradients
            -- height = 14, -- (nhường theme) Height of groupbar
            -- indicator_gap = 0, -- (nhường theme) Gap between indicator and title
            -- indicator_height = 3, -- (nhường theme) Height of indicator
            -- stacked = false, -- (nhường theme) Render as vertical stack
            -- priority = 3, -- (nhường theme) Decoration priority
            -- render_titles = true, -- (nhường theme) Render titles in decoration
            -- text_offset = 0, -- (nhường theme) Vertical position adjust for titles
            -- text_padding = 0, -- (nhường theme) Horizontal padding for titles
            -- rounding = 1, -- (nhường theme) Round indicator
            -- rounding_power = 4.0, -- (nhường theme) Curve used for rounding indicator
            -- gradient_rounding = 2, -- (nhường theme) Round gradients
            -- gradient_rounding_power = 4.0, -- (nhường theme) Curve used for rounding gradients
            -- round_only_edges = true, -- (nhường theme) Round only indicator edges
            -- gradient_round_only_edges = true, -- (nhường theme) Round only gradient edges
            -- text_color = on_surface, -- (nhường theme) Title color
            -- ["col.active"] = primary, -- (nhường theme) Active background color
            -- ["col.inactive"] = inverse_on_surface, -- (nhường theme) Inactive background color
            -- ["col.locked_active"] = tertiary, -- (nhường theme) Active locked background color
            -- ["col.locked_inactive"] = tertiary_container, -- (nhường theme) Inactive locked background color
            -- gaps_in = 2, -- (nhường theme) Gap between gradients
            -- gaps_out = 2, -- (nhường theme) Gap between gradients and window
            -- keep_upper_gap = true, -- (nhường theme) Add/remove upper gap
            -- blur = false -- (nhường theme) Apply blur to indicators and gradients
        }
    },

    -- ==========================================
    -- MISC VISUALS & UI
    -- ==========================================
    misc = {
        disable_hyprland_logo = true, -- Disables random anime girl background
        disable_splash_rendering = true, -- Disables splash rendering
        font_family = "Sans", -- Default font for debug/error text
        splash_font_family = "", -- Font for splash text
        force_default_wallpaper = 1, -- Enforce default wallpapers (-1 random, 0/1 disables anime)
        animate_manual_resizes = false, -- Animate manual window resizes/moves
        animate_mouse_windowdragging = false, -- Animate windows being dragged by mouse
        -- background_color = background, -- (nhường theme) Custom background color
        render_unfocused_fps = 60, -- Max FPS limit for unfocused background windows (60 prevents multi-tasking stutter)
        enable_anr_dialog = true -- Enable "App Not Responding" dialog
    },

    -- ==========================================
    -- RENDER PIPELINE & XWAYLAND SCALING
    -- ==========================================
    xwayland = {
        use_nearest_neighbor = true, -- Nearest neighbor filtering (pixelated vs blurry)
        force_zero_scaling = true -- Force scale of 1 on xwayland windows on scaled displays
    },

    opengl = {
        nvidia_anti_flicker = true -- Reduces flickering on nvidia (ignored on others)
    },

    render = {
        direct_scanout = 0, -- Set to 0 to prevent NVIDIA DRM plane color matrix bug (red tint on fullscreen video/apps)
        expand_undersized_textures = true, -- Expand undersized textures vs stretching entire texture
        xp_mode = false, -- Disables back buffer and bottom layer rendering
        ctm_animation = 2, -- Fade animation for CTM changes (2=auto disables on Nvidia)
        use_shader_blur_blend = false -- Blurred bg blending
    },

    -- ==========================================
    -- DEBUG VISUALS
    -- ==========================================
    debug = {
        overlay = false, -- Print debug performance overlay
        damage_blink = false, -- Flash areas updated with damage tracking
        colored_stdout_logs = true -- Colors in stdout logs
    }
})


-- -------------------------------------------------------------------------------------------------
-- SINGLE WINDOW APPEARANCE
-- Applied when exactly one tiled window is on screen (w[tv1]), or when
-- a window is maximized (f[1]). Excludes special/scratchpad workspaces (s[false]).
--
-- WHAT CANNOT BE SET HERE (window rules don't support these — global hl.config() only):
--   • rounding_power  → decoration.rounding_power in hl.config()
--   • no_shadow / no_dim → no per-window shadow or dim suppression in 0.55 window rules
--   • blur sub-options (size, passes, etc.) → decoration.blur in hl.config()
--   • border_size → must live in hl.workspace_rule(), not hl.window_rule()
-- -------------------------------------------------------------------------------------------------

-- Workspace-level: gaps + border (border_size is only valid here, not in hl.window_rule)
hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = 6, gaps_in = 4, border_size = 2 })
hl.workspace_rule({ workspace = "f[1]s[false]",   gaps_out = 8, gaps_in = 4, border_size = 1 })

-- Single tiled window
hl.window_rule({
    name  = "single_window_style",
    match = { float = false, workspace = "w[tv1]s[false]" },

    -- ROUNDING
    -- matches your global decoration.rounding = 10
    -- set to 0 for sharp corners on a lone window, or keep 10 to match global
    rounding      = 6,
    rounding_power = 4.0,
    -- OPACITY
    -- format: "active [override] inactive [override] fullscreen [override]"
    -- "override" makes it absolute instead of multiplicative with other rules
    -- your global active_opacity and inactive_opacity are both 1.0
    -- using override here so it doesn't compound with the global value
    -- opacity       = "1.0 override 1.0 override 1.0 override",
    opacity       = 1.0,

    -- BLUR
    -- false = keep blur disabled (your global decoration.blur.enabled = false)
    -- set to true to disable blur for this window only (no-op since blur is off globally)
    no_blur       = false,

    -- BORDER COLOR
    -- leave unset to inherit global col.active_border / col.inactive_border
    -- uncomment to override, e.g. a gradient:
    -- border_color = "rgb(ffffff) rgb(000000) 45deg",

    -- ANIMATION
    -- override the open/close animation for this window
    -- options: "popin", "popin 80%", "slide", "gnomed", or unset to inherit global
    -- animation = "popin 80%",

    -- TEARING
    -- allow this window to request tearing (reduce latency)
    -- matches your global allow_tearing = true, but this is per-window opt-in
    -- immediate = false,
})

-- Maximized window (f[1] = workspace has a maximized window)
hl.window_rule({
    name  = "maximized_window_style",
    match = { float = true, workspace = "f[1]s[false]" },

    rounding      = 10,
    opacity       = 1.0, -- override 0.85 override 1.0 override"
    no_blur       = true,

    -- border_color = "rgb(ffffff) rgb(000000) 45deg",
    -- animation = "popin 80%",
    -- immediate = false,
})

-- -------------------------------------------------------------------------------------------------
-- SPECIAL WORKSPACE APPEARANCE
-- "magic"  → toggled with SUPER+Z  (hl.dsp.workspace.toggle_special("magic"))
--
-- A special workspace is a floating overlay that appears on top of your current workspace.
-- The background dims according to decoration.dim_special (currently 0.7 in hl.config()).
-- The blur *behind* the overlay is controlled by decoration.blur.special (currently false).
--
-- WHAT CANNOT BE SET PER SPECIAL WORKSPACE (global hl.config() only):
--   • dim_special   → decoration.dim_special        ← already 0.8 in your hl.config()
--   • blur.special  → decoration.blur.special       ← currently false; set true to blur behind it
--   • col.active_border / col.inactive_border       ← global only; use border_color in window_rule
-- -------------------------------------------------------------------------------------------------

-- Workspace-level: gaps + border thickness for the magic scratchpad
hl.workspace_rule({
    workspace   = "special:magic",
    gaps_in     = 4,    -- gap between windows inside the scratchpad
    gaps_out    = 20,   -- large outer margin so it feels centered/floating, not edge-to-edge
    border_size = 2,    -- slightly thicker than your global 1, makes it feel distinct
})

-- Window-level: per-window appearance for everything inside special:magic
hl.window_rule({
    name           = "special_magic_style",
    match          = { workspace = "special:magic" },

    -- ROUNDING: slightly more than global 10 for a softer "popup" feel
    rounding       = 6,
    rounding_power = 4.0,

    -- OPACITY: more opaque than your global 0.85 so it pops against the dimmed background
    opacity        = 0.92,

    -- BORDER COLOR: secondary instead of primary so you can visually tell this isn't a normal window
    border_color   = outline,

    -- BLUR: keep enabled to match your global blur.enabled = true
    no_blur        = true,
})


--  ANIMATIONS
-- -------------------------------------------------------------------------------------------------

-- Sourcing active animations
require("source.animations.active.active")
