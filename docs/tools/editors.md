# Editors

## Neovim (Primary)

Primary code editor based on LazyVim distribution.

- Neovim: https://neovim.io/
- LazyVim: https://www.lazyvim.org/

### Installation

Managed by Nix Home Manager (`home/dot_config/nix/home.nix`).

### Configuration

Configuration location: `~/.config/nvim/` (source: `home/dot_config/nvim/`)

```
~/.config/nvim/
├── init.lua           # WSL clipboard setup, loads LazyVim
├── lua/
│   ├── config/        # LazyVim config overrides
│   └── plugins/       # Plugin configurations
└── stylua.toml        # Lua formatter config
```

### WSL Clipboard

Uses OSC 52 escape sequences for clipboard integration when running in WSL via SSH domain:

- **Copy**: Works via OSC 52 (yank syncs to Windows clipboard)
- **Paste**: Use `Ctrl+Shift+V` (terminal paste) - OSC 52 paste is disabled for security

### Keybindings

LazyVim uses `Space` as leader key. Common keys:

| Key | Action |
|-----|--------|
| `Space + ff` | Find files |
| `Space + fg` | Live grep |
| `Space + e` | File explorer |
| `Space + bb` | Buffer picker |
| `Ctrl + h/j/k/l` | Window navigation |

### Japanese Input (SKK)

SKK-based Japanese input method for Neovim.

- [SKK (Simple Kana to Kanji conversion)](https://ja.wikipedia.org/wiki/SKK)
- [skkeleton](https://github.com/vim-skk/skkeleton) - Main SKK input method plugin

#### System Requirements (Nix Home Manager)

- **skktools**: SKK utility tools
- **skkDictionaries.l**: Large Japanese dictionary (SKK-JISYO.L)

#### Neovim Plugins

| Plugin | Purpose |
|--------|---------|
| skkeleton | Main SKK input method |
| skkeleton-henkan-highlight | Highlight conversion candidates |
| skkeleton-snacks | snacks.nvim integration |
| vim-kensaku | Japanese search core |
| kensaku-search.vim | Japanese search with `/` |

#### Usage

| Key | Action |
|-----|--------|
| `Ctrl+j` | Toggle SKK on/off (insert/command mode) |

SKK input basics:
- Type romaji to input hiragana
- Start with uppercase for kanji conversion (e.g., `Kanji` -> select conversion)
- `q` to toggle between hiragana/katakana

#### Japanese Search (kensaku)

With kensaku-search.vim, the `/` search command supports:
- Direct Japanese input (if SKK is active)
- Romaji-to-Japanese conversion

Press `Enter` after typing romaji to search for Japanese text.

## Vim (Secondary)

Traditional Vim editor (vim-gtk3) for lightweight editing and WSL clipboard integration.

**Note**: The primary editor is Neovim with LazyVim. This vim-gtk3 installation provides `+clipboard` support for scripts and fallback editing.

- Vim: https://www.vim.org/

### Installation

- **vim-gtk3** installed via `run_once_client_ubuntu_010-apt-packages.sh.tmpl` (provides `+clipboard` support)
- Configuration: `home/dot_vimrc`
- Clipboard integration: `home/dot_vim/autoload/clipboard.vim`
- Colorscheme: Tokyo Night Storm

### Features

- **Colorscheme**: Tokyo Night Storm (change style via `g:tokyonight_style` in `~/.vimrc`)
- **Key mappings**: `j`/`k` for wrapped lines, `Y` yanks to end of line, `<Esc><Esc>` clears search highlight
- **Clipboard**:
  - Yank (`y`) syncs to system clipboard automatically
  - `<leader>p`/`<leader>P` pastes from system clipboard
  - Works across WSL (win32yank), SSH (OSC 52), X11/Wayland
  - Delete/change operations do not affect clipboard
- Japanese text support, line numbers, 2-space indentation, no backup/swap files

## See Also

- [Keybinding Design](../keybinding-design.md) - Layer 4 (Vim keybindings)
