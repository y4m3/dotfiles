# tmux

Concise notes focused on environment-specific behavior. See official docs for usage.

## Official Documentation

https://github.com/tmux/tmux

## Installation

Installed via apt in `run_onchange_client_ubuntu_000-prerequisites.sh.tmpl`.
Configuration template: `home/create_dot_tmux.conf.tmpl`.

## Environment-specific Configuration

- Vim-style navigation:
	- `prefix + h/j/k/l` to move, `prefix + H/J/K/L` to resize
- Splits:
	- `prefix + |` (vertical), `prefix + -` (horizontal)
- Clipboard integration:
	- `prefix + P` pastes from system clipboard (requires `xclip`)
- Theme:
	- Tokyo Night colors for status bar and pane borders
- Features:
	- Mouse enabled, vi copy-mode, 256 colors, renumber windows

 
