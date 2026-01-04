# zellij

Concise notes focused on environment-specific configuration. Refer to official docs for general usage.

## Official Documentation

https://github.com/zellij-org/zellij

## Installation

Managed by `run_onchange_client_ubuntu_265-zellij.sh.tmpl`. Configuration: `~/.config/zellij/config.kdl`.

## Environment-specific Configuration

- **Default Mode**: `locked` (input-first, avoids conflicts with terminal input)
- **Scroll Buffer**: 1,000,000 lines
- **Pane Frames**: Disabled (`pane_frames false`)
- **Theme**: Tokyo Night Storm
- **Keybindings**: All use `Alt` modifier to avoid conflicts with vim/bash (`Alt h/j/k/l` for pane navigation, `Alt [`/`]` for tabs, `Alt t` for new tab)

