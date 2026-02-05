## ADDED Requirements

### Requirement: Zed Terminal Toggle Command
The command palette SHALL provide a "Zed: Toggle Terminal" command that toggles Zed's integrated terminal.

#### Scenario: Toggle terminal when Zed is focused
- **WHEN** user is in the command palette
- **AND** Zed is the frontmost application
- **THEN** "Zed: Toggle Terminal" command is visible and selectable

#### Scenario: Send keystroke to toggle terminal
- **WHEN** user selects "Zed: Toggle Terminal"
- **THEN** the system sends `Ctrl+\`` keystroke to Zed
- **AND** displays "Done: Zed: Toggle Terminal" alert

#### Scenario: Command hidden when Zed is not focused
- **WHEN** user is in the command palette
- **AND** Zed is NOT the frontmost application
- **THEN** "Zed: Toggle Terminal" command is NOT visible
