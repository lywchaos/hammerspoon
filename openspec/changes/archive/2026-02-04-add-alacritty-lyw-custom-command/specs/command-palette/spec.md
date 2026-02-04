## ADDED Requirements

### Requirement: Shell Action Factory
The command palette SHALL provide a `shell` action factory that executes shell commands asynchronously via `hs.task` using `/bin/sh -c` for variable expansion.

#### Scenario: Execute shell command with environment variable
- **WHEN** a command using `Config.actions.shell("echo $HOME")` is invoked
- **THEN** the command executes asynchronously via `/bin/sh -c`
- **AND** environment variables like `$HOME` are expanded by the shell

### Requirement: Alacritty workspace Command
The command palette SHALL include a command named "Alacritty: Open workspace" that opens a new Alacritty terminal window in `$HOME/workspace`.

#### Scenario: Open terminal in workspace directory
- **WHEN** user invokes "Alacritty: Open workspace" from the command palette
- **THEN** a new Alacritty window opens with working directory `$HOME/workspace`
- **AND** a "Done: Alacritty: Open workspace" alert is displayed
