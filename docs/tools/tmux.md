# tmux

Concise notes focused on environment-specific behavior. See official docs for usage.

## Official Documentation

https://github.com/tmux/tmux

## Installation

Managed by Nix Home Manager (`home/dot_config/nix/home.nix`).

Configuration: `home/dot_tmux.conf`.

## Environment-specific Configuration

- Vim-style navigation:
	- `prefix + h/j/k/l` to move, `prefix + H/J/K/L` to resize
- Splits:
	- `prefix + |` (vertical), `prefix + -` (horizontal)
- Clipboard integration:
	- OSC 52 passthrough enabled (`set -g set-clipboard on`)
	- vi copy-mode: `y`/`Enter` copies via `~/.local/bin/clipboard-copy`
	- `prefix + P` pastes from system clipboard via `~/.local/bin/clipboard-paste`
	- Works across WSL, SSH, X11/Wayland environments
- Theme:
	- Tokyo Night colors for status bar and pane borders
- Features:
	- Mouse enabled, vi copy-mode, 256 colors, renumber windows

 
