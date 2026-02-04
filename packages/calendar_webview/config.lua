--- @module packages.calendar_webview.config
--- Configuration for calendar events and display options.

--------------------------------------------------------------------------------
-- DISABLED: Obsidian Integration
-- Intentionally disabled for a cleaner calendar UI.
-- To re-enable:
--   1. Uncomment the require below
--   2. Uncomment the usage in Config.get_all_events()
--------------------------------------------------------------------------------
-- local ObsidianReader = require("packages.calendar_webview.obsidian_reader")

local Config = {}

--- Default calendar events in FullCalendar format.
--- @type table[]
local default_events = {
    {
        title = "工作时间",
        startTime = "10:30",
        endTime = "17:00",
        daysOfWeek = { 1, 2, 3, 4, 5 },
        backgroundColor = "#3788d8",
    },
    {
        title = "可能健身",
        startTime = "16:00",
        endTime = "17:00",
        daysOfWeek = { 1, 2, 3, 4, 5 },
        backgroundColor = "#10b981",
    },
    {
        title = "可能健身",
        startTime = "13:00",
        endTime = "14:30",
        daysOfWeek = { 1, 2, 3, 4, 5 },
        backgroundColor = "#10b981",
    },
    {
        title = "做自己的事情",
        startTime = "17:00",
        endTime = "20:30",
        daysOfWeek = { 1, 2, 3, 4, 5 },
        backgroundColor = "#f59e0b",
    },
    {
        title = "终端周报",
        startTime = "13:00",
        endTime = "14:00",
        daysOfWeek = { 5 },
        backgroundColor = "#3788d8",
    },
    {
        title = "休息，别玩手机",
        startTime = "14:30",
        endTime = "14:50",
        daysOfWeek = { 5 },
        backgroundColor = "FF2F363D",
    },
}

--- Default calendar display options.
--- @type table
local default_calendar_options = {
    initialView = "timeGridDay",
    slotMinTime = "10:00:00",
    slotMaxTime = "22:00:00",
    locale = "zh-cn",
}

--- Calendar events.
--- @type table[]
Config.events = default_events

--- Calendar display options.
--- @type table
Config.calendar_options = default_calendar_options

--- Get all calendar events (default + Obsidian todos).
--- @return table[] events Merged array of all calendar events
function Config.get_all_events()
    local all_events = {}

    -- Add default hardcoded events
    for _, event in ipairs(Config.events) do
        table.insert(all_events, event)
    end

    -- Obsidian todo events disabled for cleaner UI
    -- To re-enable, uncomment the following lines:
    -- local obsidian_events = ObsidianReader.get_events()
    -- for _, event in ipairs(obsidian_events) do
    --     table.insert(all_events, event)
    -- end

    return all_events
end

return Config
