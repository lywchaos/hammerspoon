## 1. Command Palette Changes
- [x] 1.1 Add "Zed: Toggle Terminal" command to `packages/command_palette/config.lua`
  - Use `app = "Zed"` for filtering
  - Use `Config.actions.keystroke({ "ctrl" }, "\`")` for terminal toggle
  - Follow existing naming pattern: "Zed: Toggle Terminal"

## 2. Input Switcher Changes
- [x] 2.1 Add `ENGLISH_APPS` list to `packages/input_switcher/init.lua`
  - Include: "Zed", "Alacritty"
- [x] 2.2 Add `is_in_list()` generic check function (replaces `is_chinese_app()`)
- [x] 2.3 Update `on_focus_change()` to handle English apps
  - Priority: Chinese apps > English apps > default (English)

## 3. Verification
- [ ] 3.1 Reload Hammerspoon config
- [ ] 3.2 Test Zed command appears only when Zed is focused
- [ ] 3.3 Test Ctrl+` toggles terminal in Zed
- [ ] 3.4 Test input switches to English when focusing Zed
- [ ] 3.5 Test input switches to English when focusing Alacritty
- [ ] 3.6 Test input still switches to Chinese for WeChat/Feishu/etc.
