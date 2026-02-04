--- @module packages.window_manager
--- Window management utilities for Hammerspoon

local M = {}

--- Window filter for caching visible windows (event-driven updates)
--- Uses hs.window.filter which subscribes to window events and maintains an internal cache.
--- This avoids expensive synchronous queries to the OS on each call.
local window_filter = hs.window.filter.new()
    :setDefaultFilter({})
    :setOverrideFilter({ visible = true, allowRoles = 'AXStandardWindow' })

--- Helper to measure elapsed time in milliseconds.
local function elapsed_ms(start_time)
    return (hs.timer.absoluteTime() - start_time) / 1e6
end

--- Get all visible windows (cached via window filter)
--- NOTE: Some apps (e.g., Feishu/飞书, Electron-based apps) respond slowly to
--- macOS accessibility API queries, causing win:application()/app:name()/win:title()
--- to take 100-300ms per window. This is a known OS/app limitation.
--- @return table[] Array of { window = hs.window, app_name = string, title = string }
function M.get_visible_windows()
    local total_start = hs.timer.absoluteTime()
    local step_start
    local results = {}

    step_start = hs.timer.absoluteTime()
    local windows = window_filter:getWindows()
    print(string.format("  window_filter:getWindows(): %.2f ms", elapsed_ms(step_start)))

    for _, win in ipairs(windows) do
        step_start = hs.timer.absoluteTime()
        local app = win:application()
        local app_name = app and app:name() or "Unknown"
        local title = win:title()
        if title == "" or title == nil then
            title = "(untitled)"
        end
        print(string.format("    win info (%s): %.2f ms", app_name, elapsed_ms(step_start)))

        table.insert(results, {
            window = win,
            app_name = app_name,
            title = title,
        })
    end

    print(string.format("  get_visible_windows() TOTAL: %.2f ms", elapsed_ms(total_start)))
    return results
end

--- Focus a specific window
--- @param window hs.window The window object to focus
function M.focus_window(window)
    if window then
        window:focus()
    end
end

--- Position presets for snap_window
--- Each preset defines x, y offsets (as fraction of screen) and width, height (as fraction of screen)
local snap_presets = {
    ["left"]         = { x = 0,   y = 0,   w = 0.5, h = 1   },
    ["right"]        = { x = 0.5, y = 0,   w = 0.5, h = 1   },
    ["top-left"]     = { x = 0,   y = 0,   w = 0.5, h = 0.5 },
    ["top-right"]    = { x = 0.5, y = 0,   w = 0.5, h = 0.5 },
    ["bottom-left"]  = { x = 0,   y = 0.5, w = 0.5, h = 0.5 },
    ["bottom-right"] = { x = 0.5, y = 0.5, w = 0.5, h = 0.5 },
}

--- Snap the focused window to a predefined position.
--- Uses instant snap (no animation), respects menu bar/dock, stays on current screen.
--- @param position string Position preset: "left", "right", "top-left", "top-right", "bottom-left", "bottom-right"
--- @return boolean success True if window was snapped, false otherwise
function M.snap_window(position)
    local preset = snap_presets[position]
    if not preset then
        hs.alert.show("Unknown position: " .. tostring(position))
        return false
    end

    local win = hs.window.focusedWindow()
    if not win then
        hs.alert.show("No window focused")
        return false
    end

    if not win:isStandard() then
        hs.alert.show("Window cannot be resized")
        return false
    end

    -- Get usable screen area (respects menu bar and dock)
    local screen = win:screen()
    local frame = screen:frame()

    -- Calculate target frame
    local target = hs.geometry.rect(
        frame.x + frame.w * preset.x,
        frame.y + frame.h * preset.y,
        frame.w * preset.w,
        frame.h * preset.h
    )

    -- Try to set the frame
    local old_frame = win:frame()
    win:setFrame(target)

    -- Check if resize actually worked (for non-resizable windows)
    local new_frame = win:frame()
    if math.abs(new_frame.w - target.w) > 10 or math.abs(new_frame.h - target.h) > 10 then
        -- Restore original position if resize failed significantly
        win:setFrame(old_frame)
        hs.alert.show("Window cannot be resized")
        return false
    end

    return true
end

return M
