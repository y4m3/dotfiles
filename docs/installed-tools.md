# Installed Tools

Complete list of tools managed by this dotfiles repository. Each tool links to its detailed documentation.

## Prerequisites (apt)

Managed by `run_once_000-prerequisites.sh.tmpl`:

- **build-essential**, **pkg-config**, **git** (https://git-scm.com/), **jq** (https://jqlang.github.io/jq/), **tmux** ([docs](tools/tmux.md), https://github.com/tmux/tmux), **vim-gtk3** ([docs](tools/vim.md), https://www.vim.org/), **xclip**, **curl**/**wget**, **tree**, **unzip**/**tar**

## Language Runtimes

- **Rust** (rustup + cargo) | https://www.rust-lang.org/ | `run_once_100-runtimes-rust.sh.tmpl`
- **Node.js** (via Volta) | [docs](tools/nodejs.md), https://nodejs.org/, https://volta.sh/ | `run_once_110-runtimes-nodejs.sh.tmpl`
- **uv** | [docs](tools/uv.md), https://github.com/astral-sh/uv | `run_once_120-runtimes-python-uv.sh.tmpl`

## Shell & CLI Tools

- **direnv** | [docs](tools/direnv.md), https://direnv.net/ | `run_once_240-shell-direnv.sh.tmpl`
- **fzf** | [docs](tools/fzf.md), https://github.com/junegunn/fzf | `run_once_200-shell-fzf.sh.tmpl`
- **shellcheck** | [docs](tools/shellcheck-shfmt.md), https://www.shellcheck.net/ | `run_once_250-shell-shellcheck.sh.tmpl`
- **shfmt** | [docs](tools/shellcheck-shfmt.md), https://github.com/mvdan/sh | `run_once_250-shell-shellcheck.sh.tmpl`
- **yq** | [docs](tools/yq.md), https://github.com/mikefarah/yq | `run_once_275-utils-yq.sh.tmpl`
- **zoxide** | [docs](tools/zoxide.md), https://github.com/ajeetdsouza/zoxide | `run_once_210-shell-cargo-tools.sh.tmpl`

## Cargo Tools (Rust-based)

All installed via `run_once_210-shell-cargo-tools.sh.tmpl` | [docs](tools/rust-cli-tools.md)

- **bat** (https://github.com/sharkdp/bat), **eza** (https://github.com/eza-community/eza), **fd** (https://github.com/sharkdp/fd), **ripgrep (rg)** (https://github.com/BurntSushi/ripgrep), **starship** (https://starship.rs/)

## Git & Development Tools

- **delta** | [docs](tools/delta.md), https://github.com/dandavison/delta | `run_once_320-devtools-delta.sh.tmpl`
- **gh** | [docs](tools/github-tools.md), https://cli.github.com/ | `run_once_300-devtools-gh.sh.tmpl`
- **ghq** | [docs](tools/github-tools.md), https://github.com/x-motemen/ghq | `run_once_310-devtools-ghq.sh.tmpl`
- **lazygit** | [docs](tools/lazygit.md), https://github.com/jesseduffield/lazygit | `run_once_330-devtools-lazygit.sh.tmpl`

## Utilities & Monitoring

- **btop** | [docs](tools/btop.md), https://github.com/aristocratos/btop | `run_once_280-utils-btop.sh.tmpl`
- **glow** | [docs](tools/glow.md), https://github.com/charmbracelet/glow | `run_once_370-utils-glow.sh.tmpl`
- **lnav** | [docs](tools/lnav.md), https://lnav.org/ | `run_once_360-utils-lnav.sh.tmpl`
- **yazi** | [docs](tools/yazi.md), https://github.com/sxyazi/yazi | `run_once_285-utils-yazi.sh.tmpl`

## Terminal & Container Tools

- **Alacritty** | [docs](tools/alacritty.md), https://alacritty.org/ | Manual installation on Windows host required (for WSL users)
- **zellij** | [docs](tools/zellij.md), https://github.com/zellij-org/zellij | `run_once_265-terminal-zellij.sh.tmpl`
- **Docker** | [docs](tools/docker.md), https://www.docker.com/ | `run_once_350-devtools-docker.sh.tmpl` (installed on host system only)
- **lazydocker** | [docs](tools/lazydocker.md), https://github.com/jesseduffield/lazydocker | `run_once_340-devtools-lazydocker.sh.tmpl`

## Text Editors

- **vim-gtk3** | [docs](tools/vim.md), https://www.vim.org/ | `run_once_000-prerequisites.sh.tmpl` (colorscheme via `run_once_220-shell-vim-tokyonight.sh.tmpl`)

## Configuration Highlights

All tools are configured with Tokyo Night themes, vim-style keybindings, system clipboard integration, shell integration, and Nerd Fonts support.
