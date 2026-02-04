--- @module packages.focus_logger
--- Logs window focus changes to the console
local M = {}

-- State
local watcher = nil
local previous_window = nil
local debounce_timer = nil
local is_enabled = false

-- Hardcoded system UI apps to exclude
local SYSTEM_UI_APPS = {
    "Spotlight",
    "Notification Center",
    "Control Center",
    "Dock",
    "SystemUIServer",
    "loginwindow",
    "ScreenSaverEngine",
}

--- Check if app should be excluded
--- @param app_name string
--- @return boolean
local function is_system_ui(app_name)
    for _, name in ipairs(SYSTEM_UI_APPS) do
        if app_name == name then
            return true
        end
    end
    return false
end

--- Format window info for display
--- @param win hs.window|nil
--- @return string
local function format_window(win)
    if not win then
        return "[No previous window]"
    end
    local app = win:application()
    local app_name = app and app:name() or "Unknown"
    local title = win:title() or "(untitled)"
    if title == "" then
        title = "(untitled)"
    end
    return string.format("%s - %s", app_name, title)
end

--- Get current timestamp
--- @return string
local function timestamp()
    return os.date("%H:%M:%S")
end

--- Handle focus change event
--- @param new_window hs.window
local function on_focus_change(new_window)
    if not new_window then
        return
    end

    local app = new_window:application()
    local app_name = app and app:name() or "Unknown"

    -- Skip system UI
    if is_system_ui(app_name) then
        return
    end

    -- Print transition
    print(string.format(
        "\n[%s] Window Focus Changed\n  From: %s\n  To:   %s",
        timestamp(),
        format_window(previous_window),
        format_window(new_window)
    ))

    previous_window = new_window
end

--- Debounced handler for focus events
--- @param new_window hs.window
local function debounced_focus_handler(new_window)
    if debounce_timer then
        debounce_timer:stop()
    end
    debounce_timer = hs.timer.doAfter(0.1, function()
        on_focus_change(new_window)
    end)
end

--- Enable focus logging
function M.enable()
    if is_enabled then
        return
    end

    watcher = hs.window.filter.new()
    watcher:subscribe(hs.window.filter.windowFocused, debounced_focus_handler)

    is_enabled = true
    print("[Focus Logger] Enabled")
end

--- Disable focus logging
function M.disable()
    if not is_enabled then
        return
    end

    if watcher then
        watcher:unsubscribeAll()
        watcher = nil
    end
    if debounce_timer then
        debounce_timer:stop()
        debounce_timer = nil
    end
    previous_window = nil

    is_enabled = false
    print("[Focus Logger] Disabled")
end

--- Toggle focus logging on/off
function M.toggle()
    if is_enabled then
        M.disable()
    else
        M.enable()
    end
end

--- Check if focus logging is enabled
--- @return boolean
function M.is_enabled()
    return is_enabled
end

return M
