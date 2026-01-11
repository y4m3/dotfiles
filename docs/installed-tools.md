# Installed Tools

Tools managed by this dotfiles repository using Nix Home Manager and chezmoi scripts.

## Nix Home Manager (home.nix)

All tools below are installed declaratively via `~/.config/nix/home.nix`:

### Shell & Terminal

| Tool | Documentation | Website |
|------|---------------|---------|
| starship | | https://starship.rs/ |
| zellij | [docs](tools/zellij.md) | https://github.com/zellij-org/zellij |
| tmux | [docs](tools/tmux.md) | https://github.com/tmux/tmux |

### File Operations

| Tool | Documentation | Website |
|------|---------------|---------|
| bat | [docs](tools/rust-cli-tools.md) | https://github.com/sharkdp/bat |
| eza | [docs](tools/rust-cli-tools.md) | https://github.com/eza-community/eza |
| fd | [docs](tools/rust-cli-tools.md) | https://github.com/sharkdp/fd |
| ripgrep | [docs](tools/rust-cli-tools.md) | https://github.com/BurntSushi/ripgrep |
| fzf | [docs](tools/fzf.md) | https://github.com/junegunn/fzf |
| yazi | [docs](tools/yazi.md) | https://github.com/sxyazi/yazi |
| zoxide | [docs](tools/zoxide.md) | https://github.com/ajeetdsouza/zoxide |

### Git & Development

| Tool | Documentation | Website |
|------|---------------|---------|
| delta | [docs](tools/delta.md) | https://github.com/dandavison/delta |
| lazygit | [docs](tools/lazygit.md) | https://github.com/jesseduffield/lazygit |
| gh | [docs](tools/github-tools.md) | https://cli.github.com/ |
| ghq | [docs](tools/github-tools.md) | https://github.com/x-motemen/ghq |
| direnv | [docs](tools/direnv.md) | https://direnv.net/ |
| shellcheck | [docs](tools/shellcheck-shfmt.md) | https://www.shellcheck.net/ |
| shfmt | [docs](tools/shellcheck-shfmt.md) | https://github.com/mvdan/sh |
| jq | | https://jqlang.github.io/jq/ |
| yq | [docs](tools/yq.md) | https://github.com/mikefarah/yq |
| glow | [docs](tools/glow.md) | https://github.com/charmbracelet/glow |
| uv | [docs](tools/uv.md) | https://github.com/astral-sh/uv |
| just | | https://just.systems/ |

### Runtimes

| Tool | Documentation | Website |
|------|---------------|---------|
| Node.js 22 LTS | [docs](tools/nodejs.md) | https://nodejs.org/ |

### Docker & Monitoring

| Tool | Documentation | Website |
|------|---------------|---------|
| lazydocker | [docs](tools/lazydocker.md) | https://github.com/jesseduffield/lazydocker |
| btop | [docs](tools/btop.md) | https://github.com/aristocratos/btop |
| lnav | [docs](tools/lnav.md) | https://lnav.org/ |

### Dotfiles Management

| Tool | Documentation | Website |
|------|---------------|---------|
| chezmoi | | https://www.chezmoi.io/ |

## Install Scripts (home/.chezmoiscripts/)

For things that can't be managed by Nix:

| Script | Purpose |
|--------|---------|
| `run_once_..._000-apt-packages.sh.tmpl` | vim-gtk3 (WSL clipboard integration) |
| `run_once_..._010-install-nix.sh.tmpl` | Nix installation (Determinate Systems) |
| `run_after_onchange_..._100-apply-home-manager.sh.tmpl` | Home Manager switch |
| `run_onchange_..._200-wezterm.sh.tmpl` | wezterm-mux-server (apt repo) |
| `run_onchange_..._210-docker.sh.tmpl` | Docker Engine (system service) |
| `run_onchange_..._300-yazi-plugins.sh.tmpl` | yazi plugins (ya pkg add) |

### Why Not Nix?

- **vim-gtk3**: Required for WSL clipboard integration (`+clipboard` feature)
- **Nix**: Bootstrap dependency (can't install itself)
- **Docker**: System service requiring systemd integration
- **wezterm**: Uses apt repository for mux-server functionality
- **yazi plugins**: Managed via `ya pkg add` (yazi's package manager)

## Configuration Highlights

All tools are configured with:

- **Tokyo Night** colorscheme
- **Vim-style** keybindings where applicable
- **System clipboard** integration
- **Shell integration** (fzf, zoxide, direnv)
- **Nerd Fonts** support (icons in terminal)

## External Resources

Additional files managed via `.chezmoiexternal.toml`:

- **bat Tokyo Night theme**: `~/.config/bat/themes/tokyonight.tmTheme`
