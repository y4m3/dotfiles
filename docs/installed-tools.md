# Installed Tools

Complete list of tools managed by this dotfiles repository. Each tool links to its detailed documentation.

Scripts are located in `home/.chezmoiscripts/` with naming convention: `run_onchange_client_ubuntu_{number}-{name}.sh.tmpl`

## Prerequisites (apt)

Managed by `run_onchange_client_ubuntu_000-prerequisites.sh.tmpl`:

- **build-essential**, **pkg-config**, **git** (https://git-scm.com/), **jq** (https://jqlang.github.io/jq/), **tmux** ([docs](tools/tmux.md), https://github.com/tmux/tmux), **vim-gtk3** ([docs](tools/vim.md), https://www.vim.org/), **xclip**, **curl**/**wget**, **tree**, **unzip**/**tar**

## Language Runtimes

- **Rust** (rustup + cargo) | https://www.rust-lang.org/ | `run_onchange_client_ubuntu_100-rust.sh.tmpl`
- **Node.js** (via fnm) | [docs](tools/nodejs.md), https://nodejs.org/, https://github.com/Schniz/fnm | `run_onchange_client_ubuntu_110-nodejs.sh.tmpl`
- **uv** | [docs](tools/uv.md), https://github.com/astral-sh/uv | `run_onchange_client_ubuntu_120-uv.sh.tmpl`

## Shell & CLI Tools

- **direnv** | [docs](tools/direnv.md), https://direnv.net/ | `run_onchange_client_ubuntu_240-direnv.sh.tmpl`
- **fzf** | [docs](tools/fzf.md), https://github.com/junegunn/fzf | `run_onchange_client_ubuntu_200-fzf.sh.tmpl`
- **shellcheck** | [docs](tools/shellcheck-shfmt.md), https://www.shellcheck.net/ | `run_onchange_client_ubuntu_250-shellcheck.sh.tmpl`
- **shfmt** | [docs](tools/shellcheck-shfmt.md), https://github.com/mvdan/sh | `run_onchange_client_ubuntu_250-shellcheck.sh.tmpl`
- **yq** | [docs](tools/yq.md), https://github.com/mikefarah/yq | `run_onchange_client_ubuntu_275-yq.sh.tmpl`
- **zoxide** | [docs](tools/zoxide.md), https://github.com/ajeetdsouza/zoxide | `run_onchange_client_ubuntu_210-cargo-tools.sh.tmpl`

## Cargo Tools (Rust-based)

All installed via `run_onchange_client_ubuntu_210-cargo-tools.sh.tmpl` | [docs](tools/rust-cli-tools.md)

- **bat** (https://github.com/sharkdp/bat), **eza** (https://github.com/eza-community/eza), **fd** (https://github.com/sharkdp/fd), **ripgrep (rg)** (https://github.com/BurntSushi/ripgrep), **starship** (https://starship.rs/)

## Git & Development Tools

- **delta** | [docs](tools/delta.md), https://github.com/dandavison/delta | `run_onchange_client_ubuntu_320-delta.sh.tmpl`
- **gh** | [docs](tools/github-tools.md), https://cli.github.com/ | `run_onchange_client_ubuntu_300-gh.sh.tmpl`
- **ghq** | [docs](tools/github-tools.md), https://github.com/x-motemen/ghq | `run_onchange_client_ubuntu_310-ghq.sh.tmpl`
- **lazygit** | [docs](tools/lazygit.md), https://github.com/jesseduffield/lazygit | `run_onchange_client_ubuntu_330-lazygit.sh.tmpl`

## Utilities & Monitoring

- **btop** | [docs](tools/btop.md), https://github.com/aristocratos/btop | `run_onchange_client_ubuntu_280-btop.sh.tmpl`
- **glow** | [docs](tools/glow.md), https://github.com/charmbracelet/glow | `run_onchange_client_ubuntu_370-glow.sh.tmpl`
- **lnav** | [docs](tools/lnav.md), https://lnav.org/ | `run_onchange_client_ubuntu_360-lnav.sh.tmpl`
- **yazi** | [docs](tools/yazi.md), https://github.com/sxyazi/yazi | `run_onchange_client_ubuntu_285-yazi.sh.tmpl`

## Terminal & Container Tools

- **Alacritty** | [docs](tools/alacritty.md), https://alacritty.org/ | Manual installation on Windows host required (for WSL users)
- **zellij** | [docs](tools/zellij.md), https://github.com/zellij-org/zellij | `run_onchange_client_ubuntu_265-zellij.sh.tmpl`
- **Docker** | [docs](tools/docker.md), https://www.docker.com/ | `run_onchange_client_ubuntu_350-docker.sh.tmpl` (installed on host system only)
- **lazydocker** | [docs](tools/lazydocker.md), https://github.com/jesseduffield/lazydocker | `run_onchange_client_ubuntu_340-lazydocker.sh.tmpl`

## Text Editors

- **vim-gtk3** | [docs](tools/vim.md), https://www.vim.org/ | `run_onchange_client_ubuntu_000-prerequisites.sh.tmpl` (colorscheme via `run_onchange_client_ubuntu_220-vim-tokyonight.sh.tmpl`)

## Configuration Highlights

All tools are configured with Tokyo Night themes, vim-style keybindings, system clipboard integration, shell integration, and Nerd Fonts support.
