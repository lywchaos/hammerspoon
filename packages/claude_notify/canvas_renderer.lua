--- Canvas rendering for claude_notify module

local Config = require("packages.claude_notify.config")

local CanvasRenderer = {}
CanvasRenderer.__index = CanvasRenderer

--- Create a new canvas renderer instance
--- @return CanvasRenderer
function CanvasRenderer:new()
    local instance = setmetatable({}, self)
    return instance
end

--- Calculate text height for wrapping
--- @param text string
--- @param width number
--- @param font_size number
--- @return number height
local function calculate_text_height(text, width, font_size)
    if not text or text == "" then
        return 0
    end

    local styled_text = hs.styledtext.new(text, {
        font = { name = ".AppleSystemUIFont", size = font_size },
        paragraphStyle = { lineBreak = "wordWrap" },
    })

    local text_size = hs.drawing.getTextDrawingSize(styled_text, { w = width, h = 1000 })
    return math.ceil(text_size.h)
end

--- Render a notification canvas
--- @param notification table { repo_name, hook_event_name, message }
--- @param index number Position index (1 = bottom)
--- @return userdata hs.canvas instance
function CanvasRenderer:render(notification, index)
    local L = Config.Layout
    local C = Config.Colors

    local screen = hs.screen.mainScreen():frame()
    local content_width = L.WIDTH - (L.PADDING * 2)

    -- Calculate heights
    local repo_height = L.BADGE_HEIGHT
    local event_height = L.LINE_HEIGHT
    local message_height = calculate_text_height(notification.message, content_width, L.FONT_SIZE)
    if message_height == 0 then
        message_height = L.LINE_HEIGHT
    end

    local total_height = L.PADDING
        + repo_height
        + L.STACK_GAP
        + event_height
        + (notification.message ~= "" and (L.STACK_GAP + message_height) or 0)
        + L.PADDING

    -- Calculate position (stacked from bottom)
    local y = screen.h - L.MARGIN_BOTTOM - total_height
    for i = 1, index - 1 do
        y = y - (total_height + L.STACK_GAP)
    end

    local x = screen.w - L.MARGIN_RIGHT - L.WIDTH

    -- Create canvas
    local canvas = hs.canvas.new({
        x = screen.x + x,
        y = screen.y + y,
        w = L.WIDTH,
        h = total_height,
    })

    -- Background
    canvas:appendElements({
        type = "rectangle",
        action = "fill",
        roundedRectRadii = { xRadius = L.CORNER_RADIUS, yRadius = L.CORNER_RADIUS },
        fillColor = C.background,
    })

    -- Border
    canvas:appendElements({
        type = "rectangle",
        action = "stroke",
        roundedRectRadii = { xRadius = L.CORNER_RADIUS, yRadius = L.CORNER_RADIUS },
        strokeColor = C.border,
        strokeWidth = 1,
    })

    local current_y = L.PADDING

    -- Repo badge
    local badge_text = notification.repo_name
    local badge_styled = hs.styledtext.new(badge_text, {
        font = { name = ".AppleSystemUIFont", size = L.BADGE_FONT_SIZE },
    })
    local badge_text_size = hs.drawing.getTextDrawingSize(badge_styled)
    local badge_width = math.min(badge_text_size.w + L.BADGE_PADDING * 2, content_width)

    canvas:appendElements({
        type = "rectangle",
        action = "fill",
        frame = {
            x = L.PADDING,
            y = current_y,
            w = badge_width,
            h = L.BADGE_HEIGHT,
        },
        roundedRectRadii = { xRadius = 4, yRadius = 4 },
        fillColor = C.badge_background,
    })

    canvas:appendElements({
        type = "text",
        text = badge_text,
        textColor = C.badge_text,
        textSize = L.BADGE_FONT_SIZE,
        frame = {
            x = L.PADDING + L.BADGE_PADDING,
            y = current_y + 2,
            w = badge_width - L.BADGE_PADDING * 2,
            h = L.BADGE_HEIGHT,
        },
    })

    current_y = current_y + L.BADGE_HEIGHT + L.STACK_GAP

    -- Event type
    canvas:appendElements({
        type = "text",
        text = notification.hook_event_name,
        textColor = C.text_secondary,
        textSize = L.FONT_SIZE,
        frame = {
            x = L.PADDING,
            y = current_y,
            w = content_width,
            h = event_height,
        },
    })

    current_y = current_y + event_height

    -- Message
    if notification.message and notification.message ~= "" then
        current_y = current_y + L.STACK_GAP
        canvas:appendElements({
            type = "text",
            text = notification.message,
            textColor = C.text_primary,
            textSize = L.FONT_SIZE,
            frame = {
                x = L.PADDING,
                y = current_y,
                w = content_width,
                h = message_height,
            },
        })
    end

    -- Set window level and behavior
    canvas:level(hs.canvas.windowLevels.floating)
    canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)

    canvas:show()
    return canvas
end

return CanvasRenderer
