-- Keybind Manager (dusky_keybinds.py) — float, keep natural size
hl.window_rule({
    match = {
        class = "^(dusky-keybinds)$",
    },
    float = true,
    size = { 1034, 700 },
    -- size = {"monitor_w * 0.4039", "monitor_h * 0.4861"},
    center = true,
})

-- Window Rules TUI (SUPER+CTRL+ALT+A) — float, keep natural size
-- python3 • DP-2 1034×700 @ 763,370 • ws:4
hl.window_rule({
    match = {
        class = "^(dusky-winrules)$",
    },
    float = true,
    center = true,
    size = { 1424, 799 },
})

-- Animation Picker TUI (SUPER+SHIFT+A) — float, keep natural size
-- bash • DP-2 1205×659 @ 730,322 • ws:3
hl.window_rule({
    match = {
        class = "^(dusky-anim)$",
    },
    float = true,
    center = true,
    size = { 1205, 659 },
})

-- Appearance TUI (SUPER+ALT+A) — float, keep natural size
-- dusky_appearance.sh • DP-2 1307×680 @ 633,257 • ws:2
hl.window_rule({
    match = {
        class = "^(dusky-appearance)$",
    },
    float = true,
    center = true,
    size = { 1307, 680 },
})

-- pyprland scratchpad dropdown (SUPER+SHIFT+Q) — force floating so it drops
-- in from the top and stays a floating terminal regardless of pyprland's
-- own float handling on this Hyprland version.
hl.window_rule({
    match = {
        class = "^(dropdown)$",
    },
    -- Soft pale-aqua border so the scratchpad terminal stands out gently
    -- without changing the global active_border used by every other app.
    border_color = "rgb(a7d8de)",
    float = true,
})

-- AB Download Manager • DP-2 1084×600 @ 765,402 • ws:1
hl.window_rule({
    match = {
        class = "^(com-abdownloadmanager-desktop-AppKt)$",
    },
    float = true,
    center = true,
    size = { 1084, 600 },
})

-- "Nova Lock" | Omacom - Discord • DP-2 1394×839 @ 584,267 • ws:1
hl.window_rule({
    match = {
        class = "^(discord)$",
    },
    float = true,
    center = true,
    size = { 1394, 839 },
})

-- Octopi • DP-2 1264×685 @ 582,390 • ws:1
hl.window_rule({
    match = {
        class = "^(octopi)$",
    },
    float = true,
    center = true,
    size = { 1264, 685 },
})

-- ProtonPlus • DP-2 1053×733 @ 768,282 • ws:1
hl.window_rule({
    match = {
        class = "^(com\\.vysp3r\\.ProtonPlus)$",
    },
    float = true,
    center = true,
    size = { 1053, 733 },
})

-- ProtonUp-Qt - Wine/Proton Installer • DP-2 1089×714 @ 774,316 • ws:1
hl.window_rule({
    match = {
        class = "^(net\\.davidotek\\.pupgui2)$",
    },
    float = true,
    size = { 1089, 714 },
})

-- ─────────────────────────────────────────────────────────────────────────────
    center = true,
-- DUSKY CONTROL CENTER — TUI module windows (float + center, like animation/rule)
-- ─────────────────────────────────────────────────────────────────────────────

-- Input / Keyboard TUI
hl.window_rule({
    match = {
        class = "^(dusky-input)$",
    },
    float = true,
    center = true,
    size = { 1034, 700 },
})

-- Trackpad TUI
hl.window_rule({
    match = {
        class = "^(dusky-trackpad)$",
    },
    float = true,
    center = true,
    size = { 1034, 700 },
})
-- Monitors TUI
hl.window_rule({
    match = {
        class = "^(dusky-monitors)$",
    },
    float = true,
    center = true,
    size = { 1307, 680 },
})


-- Workspace Rules TUI
hl.window_rule({
    match = {
        class = "^(dusky-workspace)$",
    },
    float = true,
    center = true,
    size = { 1034, 700 },
})

-- Autostart TUI
hl.window_rule({
    match = {
        class = "^(dusky-autostart)$",
    },
    float = true,
    center = true,
    size = { 1034, 700 },
})

-- Fonts TUI
hl.window_rule({
    match = {
        class = "^(dusky-fonts)$",
    },
    float = true,
    center = true,
    size = { 1034, 700 },
})

-- Core Runner TUI
hl.window_rule({
    match = {
        class = "^(dusky-corerunner)$",
    },
    float = true,
    center = true,
    size = { 1034, 700 },
})

-- Drive Health TUI
hl.window_rule({
    match = {
        class = "^(dusky-drivehealth)$",
    },
    float = true,
    center = true,
    size = { 1034, 700 },
})

-- Package Install TUI
hl.window_rule({
    match = {
        class = "^(dusky-pkginstall)$",
    },
    float = true,
    center = true,
    size = { 900, 500 },
})

-- Package Remove TUI
hl.window_rule({
    match = {
        class = "^(dusky-pkgremove)$",
    },
    float = true,
    center = true,
    size = { 900, 500 },
})

--- Hyprmod ---
hl.window_rule({
    match = {
        class = "^(io\\.github\\.bluemancz\\.hyprmod)$",
    },
    float = true,
    center = true,
    size = { 1000, 700 },
})

-- btop • org.omarchy.btop • 960×580 (compact)
hl.window_rule({
    match = {
        class = "^(org\\.omarchy\\.btop)$",
    },
    tag = "-floating-window",
    float = true,
    center = true,
    size = { 1714, 819 },
})



-- Hình trong hình • DP-2 1368×823 @ 559,221 • ws:1
-- hl.window_rule({
--     name = "zen-float",
--     match = { class = "^(zen)$" },
--     float = true,
--     size = { 1368, 823 },
--     no_dim = true,
--     opaque = true,
--     keep_aspect_ratio = true,
--    -- size = {"monitor_w * 0.5344", "monitor_h * 0.5715"},
--     pin = true,
--     center = true,
-- })

--------------------------------------
-- CUSTOME WINDOW TRANSPARENCY RULES--
--------------------------------------


-- All windows with the title containing the word YouTube in it.
hl.window_rule({
  match   = { title = ".*YouTube.*" },
  opacity = "1 override 1 override 1.0 override",
})

-- All windows with the title matching the percice phrase "Picture in Picture"
hl.window_rule({
  match   = { title = "^(Hình trong hình|Picture-in-Picture)$" },
  opacity = "1 override 1 override 1.0 override",
})

o.window({ class = "^(zen-alpha|zen)$", title = "^(Hình trong hình|Picture-in-Picture)$" }, {
    float = true,
    pin = true,
    size = { 1368, 823 },
    center = true,-- Bạn có thể tùy chỉnh kích thước này
    opaque = true,
    no_dim = true
})

-- 2. Hộp thoại Lưu/Mở file áp dụng chung cho Zen & Firefox
o.window({ class = "^(zen.*|Zen.*|[Ff]irefox.*|org\\.mozilla\\.firefox)$", title = "^(Save|Open|Lưu|Mở|Choose|Chọn).*$" }, {
    float = true,
    center = true
})

-- Ép Shelly và tất cả các cửa sổ phụ của nó luôn nổi (float) và nằm giữa màn hình
o.window({ class = "(?i).*shelly.*" }, {
    float = true,
    center = true,
    size = "1288 713" -- Tùy chọn: Đặt kích thước mặc định cho cửa sổ (bạn có thể bỏ dòng này nếu muốn tự do)
})

-- COSMIC System Monitor • DP-2 1618×859 @ 455,241 • ws:2
hl.window_rule({
    name = "com-system76-CosmicMonitor-float",
    match = { class = "^(com\\.system76\\.CosmicMonitor)$" },
    float = true,
    size = {1618, 859},
    -- size = {"monitor_w * 0.632", "monitor_h * 0.5965"},
    center = true,
})

-- Keybindings plugin (org.quickshell)
o.window({ class = "^(org\\.quickshell)$", title = "^(Keybindings)$" }, {
    float = true,
    center = true,
    size = "1373 829"
})

-- Yoosee Camera (Wine-Staging)
-- Fix: Only float by default. Do NOT force size or center for all windows,
-- as Wine will crash when Hyprland tries to resize and center small tooltips/menus!
hl.window_rule({
    match = {
        class = "^(yoosee\\.exe|Yoosee\\.exe|steam_proton)$",
    },
    float = true,
})

hl.window_rule({
    match = {
        title = "^(Yoosee.*)$",
    },
    float = true,
})


-- Matches on title, because the Wayland backend leaves the app_id empty.
o.window({ title = "^Hyprland Hotkeys$" }, { float = true, center = true })

-- Cheat Engine Trial • DP-2 727×1004 @ 142,213 • ws:1
hl.window_rule({
    name = "cheatengine-x86_64-float",
    match = { class = "^(cheatengine-x86_64)$" },
    float = true,
    size = {727, 1004},
    -- size = {"monitor_w * 0.284", "monitor_h * 0.6972"},
    center = true,
})

-- Winetricks - choose a wineprefix • DP-2 1101×585 @ 318,304 • ws:1
hl.window_rule({
    name = "zenity-float",
    match = { class = "^(zenity)$" },
    float = true,
    size = {1101, 585},
    -- size = {"monitor_w * 0.4301", "monitor_h * 0.4062"},
    center = true,
})

-- Themebook --
o.window({ class = "^org.quickshell$", title = "^ThemeBook$" }, { tile = true })

-- omastore • DP-2 1769×1103 @ 414,162 • ws:1
hl.window_rule({
    name = "TUI-float-float",
    match = { class = "^(TUI\\.float)$" },
    float = true,
    size = {1769, 1103},
    -- size = {"monitor_w * 0.691", "monitor_h * 0.766"},
    center = true,
})



-- bap-magnify-dock • DP-2 1265×1379 @ 8,53 • ws:1
hl.window_rule({
    name = "dev-zed-Zed-float",
    match = { class = "^(dev\\.zed\\.Zed)$" },
    float = true,
    size = {1265, 1379},
    -- size = {"monitor_w * 0.4941", "monitor_h * 0.9576"},
    center = true,
})

-- bap-magnify-dock • DP-2 1265×1379 @ 8,53 • ws:1
hl.window_rule({
    name = "dev-zed-Zed-float",
    match = { class = "^(dev\\.zed\\.Zed)$" },
    float = true,
    size = {1265, 1379},
    -- size = {"monitor_w * 0.4941", "monitor_h * 0.9576"},
    center = true,
})

-- ~ · qutebrowser - qutebrowser • DP-2 2544×1379 @ 8,53 • ws:3
-- Qutebrowser window rules: match terminal 0.90 transparency
o.window("([oO]rg\\.[qQ]utebrowser\\.[qQ]utebrowser|[qQ]utebrowser)", {
  tag = "-default-opacity",
  opacity = "0.90 0.85",
})
