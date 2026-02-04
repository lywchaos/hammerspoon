--- Calendar Webview Widget Module
--- Companion widget that appears alongside the command palette.
--- @module packages.calendar_webview

local Config = require("packages.calendar_webview.config")
local CalendarWebviewRenderer = require("packages.calendar_webview.webview_renderer")

local M = {}

--- Active renderer instance.
--- @type CalendarWebviewRenderer|nil
local renderer = nil

--- Visibility polling timer.
--- @type hs.timer|nil
local visibility_timer = nil

--- Reference to the chooser being monitored.
--- @type hs.chooser|nil
local monitored_chooser = nil

--------------------------------------------------------------------------------
-- Private Functions
--------------------------------------------------------------------------------

--- Get or create renderer instance.
--- @return CalendarWebviewRenderer
local function get_renderer()
    if not renderer then
        renderer = CalendarWebviewRenderer.new()
    end
    return renderer
end

--- Stop visibility polling.
local function stop_visibility_polling()
    if visibility_timer then
        visibility_timer:stop()
        visibility_timer = nil
    end
    monitored_chooser = nil
end

--- Start polling for chooser visibility.
--- @param chooser hs.chooser
local function start_visibility_polling(chooser)
    stop_visibility_polling()

    monitored_chooser = chooser

    visibility_timer = hs.timer.doEvery(0.1, function()
        if not monitored_chooser or not monitored_chooser:isVisible() then
            M.hide()
        end
    end)
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- Show the calendar widget.
--- @param chooser hs.chooser|nil Optional chooser to monitor for auto-hide
--- @param chooser_frame table|nil Optional frame {x, y, w} of the chooser for positioning
function M.show(chooser, chooser_frame)
    local r = get_renderer()
    r:show(Config.get_all_events(), Config.calendar_options, chooser_frame)

    if chooser then
        start_visibility_polling(chooser)
    end
end

--- Hide the calendar widget.
function M.hide()
    stop_visibility_polling()

    if renderer then
        renderer:hide()
    end
end

--- Check if calendar is visible.
--- @return boolean
function M.is_visible()
    return renderer ~= nil and renderer:is_visible()
end

return M
