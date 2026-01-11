# zellij

Concise notes focused on environment-specific configuration. Refer to official docs for general usage.

## Official Documentation

https://github.com/zellij-org/zellij

## Installation

Managed by Nix Home Manager (`home/dot_config/nix/home.nix`). Configuration: `~/.config/zellij/config.kdl`.

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
| `Alt f` | Toggle floating panes |
| `Alt e` | Toggle floating ⇔ embedded |
| `Alt z` | Toggle fullscreen |
| `Alt s` | Scroll mode (then `s` for search) |
| `Alt r` | Rename pane |
| `Alt w` | Session manager |

Note: `Ctrl+g` is intentionally unbound to allow Claude Code to use it.

### Mode Navigation

- **Scroll/Search mode** (`Alt s`): Exit with `Esc` or `Enter` → Normal mode → `Alt g` → Locked
- **Rename mode** (`Alt r`): Exit with `Esc` (cancel) or `Enter` (confirm) → `Alt g` → Locked
- **Session Manager** (`Alt w`): Close plugin → `Alt g` → Locked
