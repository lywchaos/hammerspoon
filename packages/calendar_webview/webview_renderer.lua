--- Webview Renderer for Calendar Widget
--- @module packages.calendar_webview.webview_renderer

local CalendarWebviewRenderer = {}
CalendarWebviewRenderer.__index = CalendarWebviewRenderer

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

local Layout = {
    default_width = 350,
    default_height = 600,
}

--------------------------------------------------------------------------------
-- Constructor
--------------------------------------------------------------------------------

--- Create a new CalendarWebviewRenderer.
--- @return CalendarWebviewRenderer
function CalendarWebviewRenderer.new()
    local self = setmetatable({}, CalendarWebviewRenderer)
    self.webview = nil
    return self
end

--------------------------------------------------------------------------------
-- Public Methods
--------------------------------------------------------------------------------

--- Show the calendar webview.
--- @param events table[] Calendar events
--- @param calendar_options table Calendar display options
--- @param chooser_frame table|nil Optional frame {x, y, w} of the chooser for positioning
function CalendarWebviewRenderer:show(events, calendar_options, chooser_frame)
    self:hide()

    local html = self:_render_html(events, calendar_options)
    local frame = self:_calculate_frame(Layout.default_width, Layout.default_height, chooser_frame)

    self.webview = hs.webview.new(frame)
    self.webview:windowStyle({ "utility", "titled", "resizable", "closable" })
    self.webview:level(hs.canvas.windowLevels.modalPanel)
    self.webview:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    self.webview:allowTextEntry(false)
    self.webview:html(html)
    self.webview:show()
end

--- Hide and cleanup the webview.
function CalendarWebviewRenderer:hide()
    if self.webview then
        self.webview:hide()
        self.webview:delete()
        self.webview = nil
    end
end

--- Check if currently visible.
--- @return boolean
function CalendarWebviewRenderer:is_visible()
    return self.webview ~= nil
end

--------------------------------------------------------------------------------
-- Private Methods
--------------------------------------------------------------------------------

--- Render the full HTML document.
--- @param events table[] Calendar events
--- @param options table Calendar display options
--- @return string
function CalendarWebviewRenderer:_render_html(events, options)
    local events_json = hs.json.encode(events)

    local html = [[<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <title>Schedule</title>
  <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.js"></script>
  <style>
    body {
      margin: 0;
      padding: 10px;
      font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", sans-serif;
      background: #f5f5f5;
    }
    #calendar {
      background: white;
      padding: 15px;
      border-radius: 8px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    .fc-event {
      cursor: pointer;
      border: none !important;
      padding: 2px;
    }
    .fc-toolbar-title {
      font-size: 1.2em !important;
    }
  </style>
</head>
<body>
  <div id="calendar"></div>
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      const calendarEl = document.getElementById('calendar');
      const calendar = new FullCalendar.Calendar(calendarEl, {
        nowIndicator: true,
        editable: true,
        initialView: ']] .. (options.initialView or "timeGridWeek") .. [[',
        headerToolbar: {
          left: 'prev,next today',
          center: 'title',
          right: 'dayGridMonth,timeGridWeek,timeGridDay'
        },
        locale: ']] .. (options.locale or "zh-cn") .. [[',
        slotMinTime: ']] .. (options.slotMinTime or "08:00:00") .. [[',
        slotMaxTime: ']] .. (options.slotMaxTime or "22:00:00") .. [[',
        allDaySlot: false,
        height: 'auto',
        events: ]] .. events_json .. [[
      });
      calendar.render();
    });
  </script>
</body>
</html>]]

    return html
end

--- Calculate the webview frame.
--- @param default_width number Default width
--- @param default_height number Default height
--- @param chooser_frame table|nil Frame {x, y, w, h} from chooser for positioning
--- @return table
function CalendarWebviewRenderer:_calculate_frame(default_width, default_height, chooser_frame)
    local screen = hs.screen.mainScreen():frame()
    local gap = screen.w * 0.02  -- 2% gap between palette and calendar

    if chooser_frame then
        return {
            x = chooser_frame.x + chooser_frame.w + gap,
            y = chooser_frame.y,
            w = default_width,
            h = chooser_frame.h or default_height,
        }
    else
        -- Fallback: position at 32% from left (10% + 20% + 2% gap), 10% from top
        return {
            x = screen.x + (screen.w * 0.32),
            y = screen.y + (screen.h * 0.10),
            w = default_width,
            h = default_height,
        }
    end
end

return CalendarWebviewRenderer
