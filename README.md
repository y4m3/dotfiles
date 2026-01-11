# chezmoi-first setup guide

Dotfiles managed with [chezmoi](https://www.chezmoi.io/) + [Nix Home Manager](https://nix-community.github.io/home-manager/).

## Requirements

- Ubuntu 24.04+ (WSL2 supported)
- curl, git

```bash
sudo apt update && sudo apt install -y curl git
```

## Quick Start

1. Bootstrap (installs chezmoi + applies dotfiles):
```bash
curl -fsLS https://raw.githubusercontent.com/y4m3/dotfiles/main/install.sh | sh
```

2. After Nix is installed, restart shell and apply again:
```bash
exec bash
chezmoi apply
```

3. Update later:
```bash
chezmoi update
```

## Architecture

- **Nix Home Manager**: Manages 25+ CLI tools declaratively via `~/.config/nix/home.nix`
- **chezmoi**: Manages dotfiles and orchestrates installation scripts
- **Scripts**: 6 scripts for things Nix can't handle (apt packages, Docker, wezterm-mux-server)

## What's Managed

### Nix Home Manager (home.nix)

bat, btop, chezmoi, delta, direnv, eza, fd, fzf, gh, ghq, glow, jq, just,
lazydocker, lazygit, lnav, nodejs_22, ripgrep, shellcheck, shfmt, starship,
tmux, uv, yazi, yq-go, zellij, zoxide

### Install Scripts

| # | Script | Purpose |
|---|--------|---------|
| 010 | apt-packages | vim-gtk3, unzip, curl (WSL) |
| 020 | install-nix | Nix installation |
| 110 | wezterm | wezterm-mux-server |
| 120 | docker | Docker Engine |
| 135 | win32yank | WSL clipboard tool |
| 210 | apply-home-manager | Home Manager switch |
| 220 | yazi-plugins | yazi plugins |

## Development

```bash
# Linting (requires shellcheck, shfmt from Nix)
just lint
just format
just check

# Preview changes
chezmoi apply --dry-run -v
chezmoi diff

# View template variables
chezmoi data | jq
```

## Directory Structure

```
.
├── install.sh              # Bootstrap script
├── Justfile                # Lint/format tasks
├── home/
│   ├── .chezmoi.toml.tmpl  # Profile variable (client/server)
│   ├── .chezmoiscripts/    # 6 install scripts
│   ├── .chezmoiexternal.toml # External files (bat theme)
│   ├── dot_config/nix/     # Nix flake + home.nix
│   └── dot_*               # Dotfiles
└── docs/                   # Documentation
```

## Manual Setup

After `chezmoi apply`:

1. **Git config**: Edit `~/.gitconfig.local` with your name and email
2. **Shell restart**: Run `exec bash` after first Nix install
3. **Docker group**: Log out/in for docker group membership

See [Manual Setup Tasks](docs/manual-setup-tasks.md) for details.

## Documentation

- **[Manual Setup Tasks](docs/manual-setup-tasks.md)** - Complete guide for manual setup
- **[Installed Tools](docs/installed-tools.md)** - Full list of managed tools
- **[Post-Setup](docs/post-setup.md)** - Quick checklist
- **[Keybinding Design](docs/keybinding-design.md)** - Keyboard shortcuts philosophy
- **Tool-specific docs**: See `docs/tools/`

## Tips

- `create_*.tmpl` are "create-if-missing" templates; existing files are preserved
- Themed configs (delta, lazygit, zellij, yazi) use Tokyo Night colorscheme
- All tools configured for vim-style keybindings where applicable
