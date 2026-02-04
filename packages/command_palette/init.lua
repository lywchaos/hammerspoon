--- @module packages.command_palette
--- A command palette for Hammerspoon using hs.chooser.
---
--- Usage:
---   hs -c "require('packages.command_palette').show()"

local Config = require("packages.command_palette.config")
local window_manager = require("packages.window_manager")
local pinyin = require("packages.command_palette.pinyin")

local M = {}

--- Tracks the last executed command index (in-memory, reset on reload).
local last_command_index = nil

--- Check if text matches query using space-separated word matching.
--- Each word in query must be found in text (case-insensitive).
--- Supports both direct text matching and pinyin matching for Chinese characters.
--- @param text string Text to search in
--- @param query string Space-separated search query
--- @return boolean True if all words match
local function match_query(text, query)
    if query == "" then
        return true
    end
    local lower_text = text:lower()
    for word in query:gmatch("%S+") do
        local lower_word = word:lower()
        -- Try direct text match first
        if lower_text:find(lower_word, 1, true) then
            -- Word matched directly, continue to next word
        elseif pinyin.match_pinyin(text, lower_word) then
            -- Word matched via pinyin, continue to next word
        else
            -- Word didn't match either way
            return false
        end
    end
    return true
end

--- Get commands sorted by app context.
--- App-specific commands matching frontmost app are shown first.
--- Window items are appended after static commands.
--- @return table Sorted list of commands and window items
local function get_sorted_commands()
    local frontmost = hs.application.frontmostApplication()
    local app_name = frontmost and frontmost:name() or ""

    local app_commands = {}
    local global_commands = {}

    for i, cmd in ipairs(Config.commands) do
        local entry = { text = cmd.text, type = "command", index = i }
        if cmd.app == app_name then
            table.insert(app_commands, entry)
        elseif not cmd.app then
            table.insert(global_commands, entry)
        end
    end

    -- Merge: app-specific first, then global
    for _, entry in ipairs(global_commands) do
        table.insert(app_commands, entry)
    end

    -- Move last executed command to top
    if last_command_index then
        for i, entry in ipairs(app_commands) do
            if entry.index == last_command_index then
                table.remove(app_commands, i)
                table.insert(app_commands, 1, entry)
                break
            end
        end
    end

    -- Append window items
    for _, win_info in ipairs(window_manager.get_visible_windows()) do
        table.insert(app_commands, {
            text = "[Window] " .. win_info.app_name .. ": " .. win_info.title,
            type = "window",
            window = win_info.window,
        })
    end

    return app_commands
end

--- Bind a hotkey to show the command palette.
--- @param modifiers table Modifier keys (e.g., {"cmd", "shift"})
--- @param key string Key to bind
function M.bind_hotkey(modifiers, key)
    hs.hotkey.bind(modifiers, key, M.show)
end

--- Helper to measure elapsed time in milliseconds.
--- @param start_time number Start time from hs.timer.absoluteTime()
--- @return number Elapsed time in milliseconds
local function elapsed_ms(start_time)
    return (hs.timer.absoluteTime() - start_time) / 1e6
end

--- Show the command palette.
function M.show()
    local total_start = hs.timer.absoluteTime()
    local step_start

    print("=== Command Palette Profiling ===")

    -- Save current input method/layout before switching to ABC
    step_start = hs.timer.absoluteTime()
    local saved_method = hs.keycodes.currentMethod()
    print(string.format("  currentMethod(): %.2f ms", elapsed_ms(step_start)))

    step_start = hs.timer.absoluteTime()
    local saved_layout = saved_method == nil and hs.keycodes.currentLayout() or nil
    print(string.format("  currentLayout(): %.2f ms", elapsed_ms(step_start)))

    step_start = hs.timer.absoluteTime()
    hs.keycodes.setLayout("ABC")  --- avoid laggy when Chinese input method is on and switching between Chinese/English
    print(string.format("  setLayout('ABC'): %.2f ms", elapsed_ms(step_start)))

    step_start = hs.timer.absoluteTime()
    local commands = get_sorted_commands()
    print(string.format("  get_sorted_commands(): %.2f ms", elapsed_ms(step_start)))

    -- Debounce state for query filtering
    local current_query = ""
    local debounce_timer

    step_start = hs.timer.absoluteTime()
    local chooser = hs.chooser.new(function(choice)
        if debounce_timer then debounce_timer:stop() end

        -- Restore input method/layout
        if saved_method then
            hs.keycodes.setMethod(saved_method)
        elseif saved_layout then
            hs.keycodes.setLayout(saved_layout)
        end

        if choice then
            if choice.type == "window" then
                window_manager.focus_window(choice.window)
            else
                local cmd = Config.commands[choice.index]
                if cmd and cmd.action then
                    last_command_index = choice.index
                    cmd.action()
                end
            end
        end
    end)
    print(string.format("  hs.chooser.new(): %.2f ms", elapsed_ms(step_start)))

    -- Initialize debounce timer (100ms delay)
    debounce_timer = hs.timer.delayed.new(0.1, function()
        local filtered = {}
        for _, entry in ipairs(commands) do
            if match_query(entry.text, current_query) then
                table.insert(filtered, entry)
            end
        end
        chooser:choices(filtered)
    end)

    chooser:queryChangedCallback(function(query)
        current_query = query
        debounce_timer:start()
    end)

    -- Position chooser with percentage-based layout
    step_start = hs.timer.absoluteTime()
    local screen = hs.screen.mainScreen():frame()
    print(string.format("  mainScreen():frame(): %.2f ms", elapsed_ms(step_start)))

    local chooser_x = screen.x
    local chooser_y = screen.y

    step_start = hs.timer.absoluteTime()
    chooser:width(20)  -- Actually a percentage
    chooser:rows(30)  -- There is no way to set the height of the chooser, so we use rows to set the height.
    chooser:choices(commands)
    print(string.format("  chooser config (width/rows/choices): %.2f ms", elapsed_ms(step_start)))

    step_start = hs.timer.absoluteTime()
    chooser:show(hs.geometry.point(chooser_x, chooser_y))
    print(string.format("  chooser:show(): %.2f ms", elapsed_ms(step_start)))

    print(string.format("  TOTAL: %.2f ms", elapsed_ms(total_start)))
    print("=================================")
end

return M
