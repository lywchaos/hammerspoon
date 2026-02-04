--- Pinyin conversion module for Chinese character matching.
--- Provides functions to convert Chinese text to pinyin for search matching.

local pinyin_data = require("packages.command_palette.pinyin_data")

local M = {}

-- Cache for converted pinyin strings (lazy loading)
local pinyin_cache = {}

--- Check if a character is a Chinese character (CJK Unified Ideographs).
--- @param char string A single UTF-8 character
--- @return boolean True if the character is Chinese
local function is_chinese_char(char)
    local byte = string.byte(char, 1)
    -- Chinese characters in UTF-8 start with bytes 0xE4-0xE9
    return byte and byte >= 0xE4 and byte <= 0xE9
end

--- Get pinyin pronunciations for a single Chinese character.
--- @param char string A single Chinese character
--- @return table|nil Table of pinyin pronunciations, or nil if not found
function M.char_to_pinyin(char)
    return pinyin_data.dict[char]
end

--- Convert text to all possible pinyin representations.
--- For characters with multiple pronunciations, generates all combinations.
--- Non-Chinese characters pass through unchanged.
--- @param text string Text containing Chinese and/or other characters
--- @return table List of all possible pinyin strings
function M.text_to_pinyin(text)
    if not text or text == "" then
        return {""}
    end

    local results = {""}
    local i = 1
    local len = #text

    while i <= len do
        local byte = string.byte(text, i)
        local char_len = 1

        -- Determine UTF-8 character length
        if byte >= 0xF0 then
            char_len = 4
        elseif byte >= 0xE0 then
            char_len = 3
        elseif byte >= 0xC0 then
            char_len = 2
        end

        local char = text:sub(i, i + char_len - 1)
        local pinyins = M.char_to_pinyin(char)

        if pinyins then
            -- Chinese character with pinyin - expand all combinations
            local new_results = {}
            for _, result in ipairs(results) do
                for _, py in ipairs(pinyins) do
                    table.insert(new_results, result .. py)
                end
            end
            results = new_results
        else
            -- Non-Chinese character or unknown - pass through
            for j, result in ipairs(results) do
                results[j] = result .. char
            end
        end

        i = i + char_len
    end

    return results
end

--- Get cached pinyin representations for text.
--- Uses lazy caching for performance optimization.
--- @param text string Text to convert
--- @return table Cached list of pinyin strings
function M.get_cached_pinyin(text)
    if not pinyin_cache[text] then
        pinyin_cache[text] = M.text_to_pinyin(text)
    end
    return pinyin_cache[text]
end

--- Check if query matches text via pinyin.
--- Supports substring matching anywhere in the pinyin.
--- @param text string Text to search in (may contain Chinese)
--- @param query string Search query (pinyin, lowercase)
--- @return boolean True if query matches any pinyin representation
function M.match_pinyin(text, query)
    if query == "" then
        return true
    end

    local pinyins = M.get_cached_pinyin(text)
    local lower_query = query:lower()

    for _, pinyin in ipairs(pinyins) do
        if pinyin:lower():find(lower_query, 1, true) then
            return true
        end
    end

    return false
end

--- Clear the pinyin cache (useful for testing or memory management).
function M.clear_cache()
    pinyin_cache = {}
end

return M
