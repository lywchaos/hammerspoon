require("hs.ipc")
hs.ipc.cliInstall()
hs.alert.show("Hammerspoon config loaded")

-- URL event handlers (prefer over `hs -c` to avoid hs.ipc recursion)
hs.urlevent.bind("command-palette-show", function()
    require("packages.command_palette").show()
end)

hs.urlevent.bind("xunfei-toggle", function()
    require("packages.xunfei_toggle").toggle()
end)

-- Auto-start input switcher
require("packages.input_switcher")

-- Hourly notification timer
require("packages.claude_notify")

local function show_hourly_notification()
    local time_str = os.date("%H:00")
    hs.urlevent.openURL("hammerspoon://claude-notify?repo_name=⏰&hook_event_name=" .. time_str .. "&message=起身不要久坐了")
    print("show_hourly_notification: " .. time_str .. " triggered")
end

-- Start hourly notification timer
show_hourly_notification()

-- Explicitly assign this variable to avoid garbage collection
--  If that is variable to local scope. It didn't work. No idea why.
hourly_notification_timer = hs.timer.doEvery(3600, show_hourly_notification)
