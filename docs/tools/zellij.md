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

### Keybindings (all Alt-based to avoid conflicts)

| Key | Action |
|-----|--------|
| `Alt g` | Lock/Unlock mode toggle |
| `Alt h/j/k/l` | Pane navigation (vim-style) |
| `Alt ←↓↑→` | Pane navigation (arrow keys) |
| `Alt [` / `]` | Previous/Next tab |
| `Alt 1-9` | Go to tab N |
| `Alt t` | New tab |
| `Alt x` | Close pane |
| `Alt -` / `\` | Split pane down/right |
| `Alt f` | Toggle floating pane |
| `Alt s` | Scroll mode (then `s` for search) |

Note: `Ctrl+g` is intentionally unbound to allow Claude Code to use it.

