--- Claude Code notification module entry point
--- Receives notifications via hs.urlevent and displays canvas overlays

local CanvasRenderer = require("packages.claude_notify.canvas_renderer")
local NotificationStore = require("packages.claude_notify.notification_store")

local M = {}

-- Module state
local renderer = nil
local store = nil
local started = false

--- URL event handler for claude-notify
--- @param _eventName string Event name (unused)
--- @param params table URL parameters
--- @param _senderPID number Sender process ID (unused)
local function handle_notification(_eventName, params, _senderPID)
    if not store then
        return
    end

    local payload = {
        repo_name = params.repo_name or "",
        hook_event_name = params.hook_event_name or "",
        message = params.message or "",
    }

    store:add(payload)
end

--- Start the notification system
function M.start()
    if started then
        return true
    end

    -- Initialize renderer
    renderer = CanvasRenderer:new()

    -- Initialize store with renderer
    store = NotificationStore:new(renderer)

    -- Register URL event handler
    hs.urlevent.bind("claude-notify", handle_notification)

    started = true
    print("claude_notify: started with hs.urlevent")
    return true
end

--- Dismiss all active notifications
function M.dismiss_all()
    if store then
        store:dismiss_all()
    end
end

-- Auto-start on require
M.start()

return M
