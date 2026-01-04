# Vim

Concise notes focused on environment-specific configuration. Refer to official docs for general usage.

## Official Documentation

https://www.vim.org/

## Installation

- **vim-gtk3** installed via `run_onchange_client_ubuntu_000-prerequisites.sh.tmpl` (provides `+clipboard` support)
- Configuration template: `home/dot_vimrc.tmpl`
- Colorscheme installed via `run_onchange_client_ubuntu_220-vim-tokyonight.sh.tmpl`

## Environment-specific Configuration

- **Colorscheme**: Tokyo Night Storm (change style via `g:tokyonight_style` in `~/.vimrc`)
- **Key mappings**: `j`/`k` for wrapped lines, `Y` yanks to end of line, `<Esc><Esc>` clears search highlight
- **Features**: Japanese text support, clipboard integration, line numbers, 2-space indentation, no backup/swap files

For usage and advanced configuration, refer to the [Vim documentation](https://www.vim.org/docs.php).

