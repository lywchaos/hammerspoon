--- @module packages.input_switcher
--- Automatically switches input method based on focused application
local M = {}

-- Apps that should use Chinese input method (百度五笔)
local CHINESE_APPS = {
    "微信",
    "豆包",
    "飞书",
    "Obsidian",
    "Google Chrome",
}

-- Input method settings
local CHINESE_INPUT_METHOD = "百度五笔"
local ENGLISH_LAYOUT = "ABC"

-- State
local watcher = nil

--- Check if app should use Chinese input
--- @param app_name string
--- @return boolean
local function is_chinese_app(app_name)
    for _, name in ipairs(CHINESE_APPS) do
        if app_name == name then
            return true
        end
    end
    return false
end

--- Handle focus change - switch input method
local function on_focus_change(new_window)
    if not new_window then
        return
    end

    local app = new_window:application()
    local app_name = app and app:name() or "Unknown"

    if is_chinese_app(app_name) then
        hs.keycodes.setMethod(CHINESE_INPUT_METHOD)
    else
        hs.keycodes.setLayout(ENGLISH_LAYOUT)
    end
end

--- Start the input switcher (called on module load)
local function start()
    watcher = hs.window.filter.new()
    watcher:subscribe(hs.window.filter.windowFocused, on_focus_change)
end

-- Auto-start on require
start()

return M
