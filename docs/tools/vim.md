# Vim

Concise notes focused on environment-specific configuration. Refer to official docs for general usage.

## Official Documentation

https://www.vim.org/

## Installation

- **vim-gtk3** installed via `run_once_client_ubuntu_010-apt-packages.sh.tmpl` (provides `+clipboard` support)
- Configuration: `home/dot_vimrc`
- Clipboard integration: `home/dot_vim/autoload/clipboard.vim`
- Colorscheme: Tokyo Night Storm

## Environment-specific Configuration

- **Colorscheme**: Tokyo Night Storm (change style via `g:tokyonight_style` in `~/.vimrc`)
- **Key mappings**: `j`/`k` for wrapped lines, `Y` yanks to end of line, `<Esc><Esc>` clears search highlight
- **Clipboard**:
	- Yank (`y`) syncs to system clipboard automatically
	- `<leader>p`/`<leader>P` pastes from system clipboard
	- Works across WSL (win32yank), SSH (OSC 52), X11/Wayland
	- Delete/change operations do not affect clipboard
- **Features**: Japanese text support, line numbers, 2-space indentation, no backup/swap files

For usage and advanced configuration, refer to the [Vim documentation](https://www.vim.org/docs.php).
