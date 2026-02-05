## ADDED Requirements

### Requirement: English Input Switching for Code Editors
The input switcher SHALL automatically switch to English (ABC) input method when focusing code editors that primarily require English input.

#### Scenario: Switch to English when focusing Zed
- **WHEN** user focuses a Zed window
- **THEN** input method switches to "ABC" English layout

#### Scenario: Switch to English when focusing Alacritty
- **WHEN** user focuses an Alacritty terminal window
- **THEN** input method switches to "ABC" English layout

### Requirement: Priority Order for Input Method Switching
The input switcher SHALL respect the following priority order when determining which input method to use:
1. Chinese apps (WeChat, Feishu, etc.) → Chinese input method
2. English apps (Zed, Alacritty) → English layout
3. All other apps → English layout (default)

#### Scenario: Chinese apps take priority over default
- **WHEN** user focuses WeChat
- **THEN** input method switches to "百度五笔" (Chinese)

#### Scenario: English apps use English layout
- **WHEN** user focuses Zed
- **AND** Zed is in the ENGLISH_APPS list
- **THEN** input method switches to "ABC" layout

#### Scenario: Unlisted apps default to English
- **WHEN** user focuses an app not in CHINESE_APPS or ENGLISH_APPS
- **THEN** input method switches to "ABC" layout (unchanged behavior)
