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

-- Apps that should always use English input (code editors, terminals)
local ENGLISH_APPS = {
    "Zed",
    "Alacritty",
}

-- Input method settings
local CHINESE_INPUT_METHOD = "百度五笔"
local ENGLISH_LAYOUT = "ABC"

-- State
local watcher = nil

--- Check if app name is in the given list
--- @param app_name string
--- @param app_list table
--- @return boolean
local function is_in_list(app_name, app_list)
    for _, name in ipairs(app_list) do
        if app_name == name then
            return true
        end
    end
    return false
end

--- Handle focus change - switch input method
--- Priority: Chinese apps > English apps > default (English)
local function on_focus_change(new_window)
    if not new_window then
        return
    end

    local app = new_window:application()
    local app_name = app and app:name() or "Unknown"

    if is_in_list(app_name, CHINESE_APPS) then
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
