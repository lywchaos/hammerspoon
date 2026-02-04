# Change: Add Alacritty lyw_custom Command

## Why
User frequently works in `$HOME/workspace` and wants quick command palette access to open a terminal there. Alacritty runs as a daemon, making `alacritty msg create-window` the appropriate method.

## What Changes
- Add `shell` action factory to `Config.actions` for reusable async shell command execution
- Add "Alacritty: Open workspace" command to the palette

## Impact
- Affected specs: command-palette
- Affected code: `packages/command_palette/config.lua`
