# AGENTS.md

About user script written in hammerspoon.

## What's Hammerspoon

Hammerspoon is a desktop automation tool for macOS. It bridges various system level APIs into a Lua scripting engine, allowing you to have powerful effects on your system by writing Lua scripts.

references:
- [Hammerspoon Get Started](https://www.hammerspoon.org/go/)
- [Hammerspoon Api Document](https://www.hammerspoon.org/docs/index.html)

## Directory Structure

- init.lua: entrypoint
- hammerspoon_api_docs.json: This is the complete Hammerspoon API documentation. Refer to it proactively if you are unsure about any API usage.
- packages/

## Code Patterns

- Module pattern: `local M = {} ... return M`
- `hs` is a global provided by Hammerspoon runtime - linter "undefined global" warnings for `hs` are expected and safe to ignore
- Adding command palette items: edit `packages/command_palette/config.lua`, add `{ text = "Name", action = function() ... end }` to `Config.commands`
- Window positioning: use `screen:frame()` (respects menu bar/dock) not `screen:fullFrame()`