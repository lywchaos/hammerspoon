<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

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
- Shell commands (`hs.task`, `hs.execute`): use full paths (e.g., `/opt/homebrew/bin/alacritty`) - Hammerspoon has minimal PATH, won't find executables in user's shell PATH