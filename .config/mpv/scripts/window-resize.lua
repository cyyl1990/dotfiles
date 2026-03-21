local mp = require 'mp'
local msg = require 'mp.msg'

-- Cho phép resize bằng chuột ở các góc
local function enable_window_resize()
    -- Đặt property để cửa sổ có thể resize
    mp.set_property("window-resizable", "yes")
    mp.set_property("keepaspect", "no")
    mp.osd_message("Window resize: ENABLED", 2)
end

local function disable_window_resize()
    mp.set_property("window-resizable", "no")
    mp.set_property("keepaspect", "yes")
    mp.osd_message("Window resize: DISABLED", 2)
end

-- Toggle resize mode
local resize_enabled = false
function toggle_resize()
    resize_enabled = not resize_enabled
    if resize_enabled then
        enable_window_resize()
    else
        disable_window_resize()
    end
end

-- Key bindings
mp.add_key_binding("Ctrl+Shift+r", "toggle-resize", toggle_resize)
mp.add_key_binding("Ctrl+Alt+r", "enable-resize", enable_window_resize)
mp.add_key_binding("Ctrl+Alt+Shift+r", "disable-resize", disable_window_resize)

-- Auto-disable khi vào fullscreen
mp.observe_property("fullscreen", "bool", function(_, fullscreen)
    if fullscreen then
        disable_window_resize()
    end
end)

msg.info("Window resize script loaded. Ctrl+Shift+r to toggle.")
