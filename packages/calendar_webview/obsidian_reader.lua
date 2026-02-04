--- @module packages.calendar_webview.obsidian_reader
--- Reads Obsidian vault todos and converts them to calendar events.
---
--- STATUS: DISABLED
--- This module is intentionally disabled for a cleaner calendar UI.
--- The require statement in config.lua is commented out.
--- To re-enable: uncomment the require and usage in config.lua

local M = {}

--- Default background color for Obsidian todo events.
local OBSIDIAN_EVENT_COLOR = "#8b5cf6"

--- Default far-future end time for todos without due date.
--- Creates visual pressure to set proper due dates.
local DEFAULT_FAR_FUTURE_DUE = "9999-12-31T23:59:59"

--- Treat literal "\"\"" YAML values as empty.
--- Some files encode an empty string as two quote characters.
--- @param value string|nil
--- @return boolean
local function is_effectively_empty(value)
    if value == nil then
        return true
    end
    if type(value) ~= "string" then
        return false
    end

    local trimmed = value:match("^%s*(.-)%s*$")
    return trimmed == "" or trimmed == "\"\"" or trimmed == "''"
end

--- Path to the vault path configuration file.
--- @type string
local vault_path_file = "/Users/liangyuanwei/work/repos/ai-coding-assistance-config-summary/common_files/obsidian_vault_path.txt"

--------------------------------------------------------------------------------
-- Private Functions
--------------------------------------------------------------------------------

--- Read the Obsidian vault path from configuration file.
--- @return string|nil vault_path The vault path or nil if not configured
local function read_vault_path()
    local file = io.open(vault_path_file, "r")
    if not file then
        hs.logger.new("obsidian_reader"):w("Vault path file not found: " .. vault_path_file)
        return nil
    end

    local content = file:read("*all")
    file:close()

    local path = content:match("^%s*(.-)%s*$") -- trim whitespace
    if path == "" then
        hs.logger.new("obsidian_reader"):w("Vault path file is empty")
        return nil
    end

    return path
end

--- List markdown files in the todos directory (non-recursive).
--- @param vault_path string
--- @return string[] file_paths
local function list_todo_files(vault_path)
    local todos_dir = vault_path .. "/todos"
    local files = {}

    local iter, dir_obj = hs.fs.dir(todos_dir)
    if not iter then
        hs.logger.new("obsidian_reader"):w("Cannot read todos directory: " .. todos_dir)
        return files
    end

    for filename in iter, dir_obj do
        if filename:match("%.md$") then
            table.insert(files, todos_dir .. "/" .. filename)
        end
    end

    return files
end

--- Parse YAML frontmatter from markdown content.
--- @param content string
--- @return table|nil frontmatter Parsed frontmatter or nil if invalid
local function parse_frontmatter(content)
    local frontmatter_text = content:match("^%-%-%-\n(.-)%-%-%-")
    if not frontmatter_text then
        return nil
    end

    local frontmatter = {}

    for line in frontmatter_text:gmatch("[^\n]+") do
        local key, value = line:match("^([%w_]+):%s*(.+)$")
        if key and value then
            -- Remove surrounding quotes if present
            value = value:match("^[\"'](.+)[\"']$") or value
            frontmatter[key] = value
        end
    end

    return frontmatter
end

--- Extract title from file path (filename without extension, time prefix removed).
--- @param file_path string
--- @return string title
local function extract_title(file_path)
    local filename = file_path:match("([^/]+)%.md$")
    if not filename then
        return "Untitled"
    end

    -- Remove common time prefixes:
    -- The prefix is like "2025-07-06T19-47-02"
    local title = filename:match("^%d%d%d%d%-%d%d%-%d%dT%d%d%-%d%d%-%d%d(.+)$")
    if title then
        return title
    end

    return filename
end

--- Resolve end time from frontmatter with priority: ended_at > due > far-future default.
--- @param frontmatter table
--- @return string end_time
local function resolve_end_time(frontmatter)
    if not is_effectively_empty(frontmatter.ended_at) then
        return frontmatter.ended_at
    end
    if not is_effectively_empty(frontmatter.due) then
        return frontmatter.due
    end
    return DEFAULT_FAR_FUTURE_DUE
end

--- Convert a todo file to FullCalendar event format.
--- @param file_path string
--- @return table|nil event FullCalendar event or nil if invalid
local function file_to_event(file_path)
    local file = io.open(file_path, "r")
    if not file then
        hs.logger.new("obsidian_reader"):w("Cannot read file: " .. file_path)
        return nil
    end

    local content = file:read("*all")
    file:close()

    local frontmatter = parse_frontmatter(content)
    if not frontmatter then
        hs.logger.new("obsidian_reader"):w("No frontmatter found in: " .. file_path)
        return nil
    end

    if not frontmatter.time then
        hs.logger.new("obsidian_reader"):w("Missing time in: " .. file_path)
        return nil
    end

    return {
        title = extract_title(file_path),
        start = frontmatter.time,
        ["end"] = resolve_end_time(frontmatter),
        backgroundColor = OBSIDIAN_EVENT_COLOR,
    }
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- Read all Obsidian todos and convert to calendar events.
--- @return table[] events Array of FullCalendar events
function M.get_events()
    local vault_path = read_vault_path()
    if not vault_path then
        return {}
    end

    local files = list_todo_files(vault_path)
    local events = {}

    for _, file_path in ipairs(files) do
        local event = file_to_event(file_path)
        if event then
            table.insert(events, event)
        end
    end

    return events
end

return M
