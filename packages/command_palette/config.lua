--- @module packages.command_palette.config
--- Command definitions and action factories for the command palette.

local claude_notify = require("packages.claude_notify")
local focus_logger = require("packages.focus_logger")
local window_manager = require("packages.window_manager")

local Config = {}

local function notify_action_done(action_text)
    hs.alert.show(string.format("Done: %s", action_text))
end

--- Action factories for creating command actions.
Config.actions = {
    --- Send a keystroke with modifiers.
    --- @param modifiers table Modifier keys (e.g., {"ctrl", "shift"})
    --- @param key string Key to press
    --- @return function Action function
    keystroke = function(modifiers, key)
        return function()
            hs.eventtap.keyStroke(modifiers, key)
        end
    end,

    --- Send a sequence of keystrokes.
    --- @param keys table List of keys to press in order
    --- @return function Action function
    sequence = function(keys)
        return function()
            for _, key in ipairs(keys) do
                hs.eventtap.keyStroke({}, key)
            end
        end
    end,

    --- Execute an AppleScript via osascript.
    --- @param script string AppleScript code to execute
    --- @return function Action function
    osascript = function(script)
        return function()
            hs.osascript.applescript(script)
        end
    end,

    --- Execute a shell command asynchronously.
    --- @param cmd string Shell command to execute (supports variable expansion)
    --- @return function Action function
    shell = function(cmd)
        return function()
            hs.task.new("/bin/sh", nil, { "-l", "-c", cmd }):start()
        end
    end,
}

--- Command definitions.
--- Each command has:
---   - text: Display name (also used for search)
---   - action: Function to execute
---   - app: (optional) App-specific command, only shown when app is frontmost
Config.commands = {
    {
        text = "Reload Hammerspoon Config",
        action = function()
            hs.reload()
            notify_action_done("Reload Hammerspoon Config")
        end,
    },
    {
        text = "Dismiss Claude Notifications",
        action = function()
            claude_notify.dismiss_all()
            notify_action_done("Dismiss Claude Notifications")
        end,
    },
    {
        text = "Cursor: Search Word",
        app = "Cursor",
        action = function()
            Config.actions.sequence({ "\\", "\\", "2", "s" })()
            notify_action_done("Cursor: Search Word")
        end,
    },
    {
        text = "Cursor: Toggle Terminal",
        app = "Cursor",
        action = function()
            Config.actions.keystroke({ "ctrl" }, "`")()
            notify_action_done("Cursor: Toggle Terminal")
        end,
    },
    {
        text = "Music Next",
        action = function()
            Config.actions.osascript("tell application \"Music\" to next track")()
            notify_action_done("Music Next")
        end,
    },
    {
        text = "Music Previous",
        action = function()
            Config.actions.osascript("tell application \"Music\" to previous track")()
            notify_action_done("Music Previous")
        end,
    },
    {
        text = "Maximize Window",
        action = function()
            local win = hs.window.focusedWindow()
            if win then
                win:maximize()
                notify_action_done("Maximize Window")
            else
                hs.alert.show("No focused window")
            end
        end,
    },
    {
        text = "Toggle Focus Logger",
        action = function()
            focus_logger.toggle()
            local status = focus_logger.is_enabled() and "ON" or "OFF"
            hs.alert.show("Focus Logger: " .. status)
        end,
    },
    {
        text = "Snap Window Left",
        action = function()
            window_manager.snap_window("left")
        end,
    },
    {
        text = "Snap Window Right",
        action = function()
            window_manager.snap_window("right")
        end,
    },
    {
        text = "Snap Window Top Left",
        action = function()
            window_manager.snap_window("top-left")
        end,
    },
    {
        text = "Snap Window Top Right",
        action = function()
            window_manager.snap_window("top-right")
        end,
    },
    {
        text = "Snap Window Bottom Left",
        action = function()
            window_manager.snap_window("bottom-left")
        end,
    },
    {
        text = "Snap Window Bottom Right",
        action = function()
            window_manager.snap_window("bottom-right")
        end,
    },
    {
        text = "Alacritty: Open workspace",
        action = function()
            Config.actions.shell("/opt/homebrew/bin/alacritty msg create-window --working-directory $HOME/workspace")()
        end,
    },
}

return Config
