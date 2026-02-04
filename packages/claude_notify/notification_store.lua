--- Notification state management for claude_notify module

local Config = require("packages.claude_notify.config")

--- @class Notification
--- @field id string Unique identifier
--- @field repo_name string Repository name for window matching
--- @field hook_event_name string Hook event type
--- @field message string Display message
--- @field canvas userdata hs.canvas instance
--- @field created_at number Timestamp

--- @class NotificationStore
--- @field notifications Notification[] Active notifications (max 5)
--- @field window_watcher userdata hs.window.filter for focus detection
--- @field renderer table Canvas renderer module reference
local NotificationStore = {}
NotificationStore.__index = NotificationStore

--- Create a new notification store instance
--- @param renderer table Canvas renderer module
--- @return NotificationStore
function NotificationStore:new(renderer)
    local instance = setmetatable({}, self)
    instance.notifications = {}
    instance.renderer = renderer
    instance:_setup_window_watcher()
    return instance
end

--- Generate a unique notification ID
--- @return string
local function generate_id()
    return tostring(hs.timer.absoluteTime())
end

--- Add a new notification
--- @param payload table { repo_name: string, hook_event_name: string, message: string }
function NotificationStore:add(payload)
    -- Enforce max limit with FIFO eviction
    while #self.notifications >= Config.MAX_NOTIFICATIONS do
        self:_dismiss_oldest()
    end

    local notification = {
        id = generate_id(),
        repo_name = payload.repo_name or "",
        hook_event_name = payload.hook_event_name or "",
        message = payload.message or "",
        canvas = nil,
        created_at = os.time(),
    }

    table.insert(self.notifications, notification)

    -- Render all notifications to update positions
    self:_render_all()
end

--- Dismiss a notification by ID
--- @param id string Notification ID
function NotificationStore:dismiss(id)
    for i, notif in ipairs(self.notifications) do
        if notif.id == id then
            self:_cleanup_canvas(notif)
            table.remove(self.notifications, i)
            self:_render_all()
            return
        end
    end
end

--- Dismiss all notifications without full cleanup
function NotificationStore:dismiss_all()
    for _, notif in ipairs(self.notifications) do
        self:_cleanup_canvas(notif)
    end
    self.notifications = {}
end

--- Dismiss the oldest notification
function NotificationStore:_dismiss_oldest()
    if #self.notifications > 0 then
        local oldest = self.notifications[1]
        self:_cleanup_canvas(oldest)
        table.remove(self.notifications, 1)
    end
end

--- Clean up a notification's canvas
--- @param notification Notification
function NotificationStore:_cleanup_canvas(notification)
    if notification.canvas then
        notification.canvas:hide()
        notification.canvas:delete()
        notification.canvas = nil
    end
end

--- Render all notifications with updated positions
function NotificationStore:_render_all()
    for i, notif in ipairs(self.notifications) do
        self:_cleanup_canvas(notif)
        notif.canvas = self.renderer:render(notif, i)
    end
end

--- Setup window focus watcher for auto-dismiss
function NotificationStore:_setup_window_watcher()
    self.window_watcher = hs.window.filter.new()
    self.window_watcher:subscribe(hs.window.filter.windowFocused, function(window)
        if not window then return end
        local title = window:title() or ""
        local title_lower = title:lower()

        for _, notif in ipairs(self.notifications) do
            if title_lower:find(notif.repo_name:lower(), 1, true) then
                self:dismiss(notif.id)
                break
            end
        end
    end)
end

return NotificationStore
