--- Configuration constants for claude_notify module

local M = {}

--- Notification limits
M.MAX_NOTIFICATIONS = 5

--- Layout constants
M.Layout = {
    WIDTH = 300,
    PADDING = 16,
    MARGIN_RIGHT = 20,
    MARGIN_BOTTOM = 20,
    STACK_GAP = 10,
    CORNER_RADIUS = 8,
    BADGE_HEIGHT = 20,
    BADGE_PADDING = 8,
    LINE_HEIGHT = 18,
    FONT_SIZE = 13,
    BADGE_FONT_SIZE = 11,
}

--- Color scheme
M.Colors = {
    -- Background
    background = { red = 0.15, green = 0.15, blue = 0.18, alpha = 0.95 },
    border = { red = 0.3, green = 0.3, blue = 0.35, alpha = 1.0 },

    -- Text
    text_primary = { red = 1.0, green = 1.0, blue = 1.0, alpha = 1.0 },
    text_secondary = { red = 0.7, green = 0.7, blue = 0.7, alpha = 1.0 },

    -- Badge
    badge_background = { red = 0.25, green = 0.5, blue = 0.8, alpha = 1.0 },
    badge_text = { red = 1.0, green = 1.0, blue = 1.0, alpha = 1.0 },
}

return M
