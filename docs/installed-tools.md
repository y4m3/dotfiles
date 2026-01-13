# Installed Tools

Tools managed by this dotfiles repository using Nix Home Manager and chezmoi scripts.

## Nix Home Manager (home.nix)

All tools below are installed declaratively via `~/.config/nix/home.nix`:

### Editors

| Tool | Documentation | Website |
|------|---------------|---------|
| neovim | [docs](tools/editors.md#neovim) | https://neovim.io/ |
| vim | [docs](tools/editors.md#vim) | https://www.vim.org/ |

### Shell & Terminal

| Tool | Documentation | Website |
|------|---------------|---------|
| wezterm | [docs](tools/terminals.md#wezterm-primary) | https://wezfurlong.org/wezterm/ |
| alacritty | [docs](tools/terminals.md#alacritty-alternative) | https://alacritty.org/ |
| starship | [docs](tools/cli-tools.md#starship) | https://starship.rs/ |
| zellij | [docs](tools/terminals.md#zellij) | https://github.com/zellij-org/zellij |
| tmux | [docs](tools/terminals.md#tmux) | https://github.com/tmux/tmux |

### File Operations

| Tool | Documentation | Website |
|------|---------------|---------|
| bat | [docs](tools/cli-tools.md#bat) | https://github.com/sharkdp/bat |
| eza | [docs](tools/cli-tools.md#eza) | https://github.com/eza-community/eza |
| fd | [docs](tools/cli-tools.md#fd) | https://github.com/sharkdp/fd |
| ripgrep | [docs](tools/cli-tools.md#ripgrep-rg) | https://github.com/BurntSushi/ripgrep |
| fzf | [docs](tools/cli-tools.md#fzf) | https://github.com/junegunn/fzf |
| yazi | [docs](tools/cli-tools.md#yazi) | https://github.com/sxyazi/yazi |
| zoxide | [docs](tools/cli-tools.md#zoxide) | https://github.com/ajeetdsouza/zoxide |
| glow | [docs](tools/cli-tools.md#glow) | https://github.com/charmbracelet/glow |

### Git

| Tool | Documentation | Website |
|------|---------------|---------|
| delta | [docs](tools/git-tools.md#delta) | https://github.com/dandavison/delta |
| lazygit | [docs](tools/git-tools.md#lazygit) | https://github.com/jesseduffield/lazygit |
| gh | [docs](tools/git-tools.md#gh-github-cli) | https://cli.github.com/ |
| ghq | [docs](tools/git-tools.md#ghq) | https://github.com/x-motemen/ghq |

### Python Development

| Tool | Documentation | Website |
|------|---------------|---------|
| uv | [docs](tools/dev-tools.md#uv) | https://github.com/astral-sh/uv |
| pyright | [docs](tools/dev-tools.md#pyright) | https://github.com/microsoft/pyright |
| ruff | [docs](tools/dev-tools.md#ruff) | https://github.com/astral-sh/ruff |

### Development Tools

| Tool | Documentation | Website |
|------|---------------|---------|
| direnv | [docs](tools/dev-tools.md#direnv) | https://direnv.net/ |
| shellcheck | [docs](tools/dev-tools.md#shellcheck) | https://www.shellcheck.net/ |
| shfmt | [docs](tools/dev-tools.md#shfmt) | https://github.com/mvdan/sh |
| jq | [docs](tools/dev-tools.md#jq) | https://jqlang.github.io/jq/ |
| yq | [docs](tools/dev-tools.md#yq) | https://github.com/mikefarah/yq |
| just | [docs](tools/dev-tools.md#just) | https://just.systems/ |
| prettier | [docs](tools/dev-tools.md#prettier) | https://prettier.io/ |
| markdownlint-cli2 | [docs](tools/dev-tools.md#markdownlint) | https://github.com/DavidAnson/markdownlint-cli2 |
| mermaid-cli | [docs](tools/dev-tools.md#mermaid-cli) | https://github.com/mermaid-js/mermaid-cli |
| ast-grep | [docs](tools/dev-tools.md#ast-grep) | https://ast-grep.github.io/ |

### Japanese Input

| Tool | Documentation | Website |
|------|---------------|---------|
| skktools | [docs](tools/editors.md#japanese-input-skk) | https://github.com/skk-dev/skktools |
| skkDictionaries | [docs](tools/editors.md#japanese-input-skk) | https://github.com/skk-dev/dict |

### Runtimes

| Tool | Documentation | Website |
|------|---------------|---------|
| Node.js 22 LTS | [docs](tools/dev-tools.md#nodejs) | https://nodejs.org/ |
| deno | [docs](tools/dev-tools.md#deno) | https://deno.land/ |

### Docker & Monitoring

| Tool | Documentation | Website |
|------|---------------|---------|
| docker | [docs](tools/infra-tools.md#docker) | https://www.docker.com/ |
| lazydocker | [docs](tools/infra-tools.md#lazydocker) | https://github.com/jesseduffield/lazydocker |
| btop | [docs](tools/infra-tools.md#btop) | https://github.com/aristocratos/btop |
| lnav | [docs](tools/infra-tools.md#lnav) | https://lnav.org/ |

### Dotfiles Management

| Tool | Documentation | Website |
|------|---------------|---------|
| chezmoi | [docs](tools/chezmoi.md) | https://www.chezmoi.io/ |

## Install Scripts (home/.chezmoiscripts/)

For things that can't be managed by Nix:

| Script | Purpose |
|--------|---------|
| `run_once_..._010-apt-packages.sh.tmpl` | vim-gtk3, unzip, curl (WSL clipboard) |
| `run_once_..._020-install-nix.sh.tmpl` | Nix installation (Determinate Systems) |
| `run_onchange_..._110-wezterm.sh.tmpl` | wezterm-mux-server (apt repo) |
| `run_onchange_..._120-docker.sh.tmpl` | Docker Engine (system service) |
| `run_onchange_..._135-win32yank.sh.tmpl` | win32yank (WSL clipboard tool) |
| `run_after_onchange_..._210-apply-home-manager.sh.tmpl` | Home Manager switch |
| `run_after_onchange_..._215-bat-cache.sh.tmpl` | bat theme cache rebuild |
| `run_after_onchange_..._220-yazi-plugins.sh.tmpl` | yazi plugins (ya pkg add) |

### Why Not Nix?

- **vim-gtk3**: Required for WSL clipboard integration (`+clipboard` feature)
- **Nix**: Bootstrap dependency (can't install itself)
- **Docker**: System service requiring systemd integration
- **wezterm**: Uses apt repository for mux-server functionality
- **win32yank**: Windows executable for WSL clipboard (not available in Nix)
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
