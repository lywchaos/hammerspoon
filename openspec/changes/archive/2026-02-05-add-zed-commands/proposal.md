# Change: Add Zed Commands and English Input Switching

## Why
User is migrating from Cursor to Zed as their primary code editor. The Hammerspoon command palette needs Zed-specific commands to mirror existing Cursor functionality. Additionally, the input_switcher should auto-switch to English for code editors and terminals to improve typing workflow.

## What Changes
1. **Command Palette**: Add "Zed: Toggle Terminal" command (mirrors existing Cursor command)
2. **Input Switcher**: Add English input method switching for:
   - Zed (code editor)
   - Alacritty (terminal)

Note: "Cursor: Search Word" is skipped per user request (custom vim binding not needed in Zed).

## Impact
- Affected specs: command-palette, input-switcher
- Affected code:
  - `packages/command_palette/config.lua` - Add Zed commands
  - `packages/input_switcher/init.lua` - Add ENGLISH_APPS list and switching logic

## Design Decisions
- Keep existing Cursor commands (user uses both editors during transition)
- Use `app = "Zed"` for filtering (standard Zed.app, not Zed Preview)
- Follow existing naming convention: "Zed: Action Name"
- Use `Ctrl+\`` keybinding (same as Cursor toggle terminal)
- English input source: "ABC" layout (macOS standard)
