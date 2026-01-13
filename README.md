# chezmoi-first setup guide

Dotfiles managed with [chezmoi](https://www.chezmoi.io/) + [Nix Home Manager](https://nix-community.github.io/home-manager/).

## Requirements

- Ubuntu 24.04+ (WSL2 supported)
  - curl, git

## Quick Start

```bash
# 1. Bootstrap
curl -fsLS https://raw.githubusercontent.com/y4m3/dotfiles/main/install.sh | sh

# 2. Restart shell after Nix install, then apply again
exec bash && chezmoi apply

# 3. Update later
chezmoi update
```

## Architecture

- **Nix Home Manager**: 25+ CLI tools via `~/.config/nix/home.nix`
- **chezmoi**: Dotfiles + 6 install scripts (apt, Nix, wezterm, docker, win32yank, yazi)

## Directory Structure

```
.
├── install.sh              # Bootstrap script
├── Justfile                # Lint/format tasks
├── home/
│   ├── .chezmoi.toml.tmpl  # Profile variable (client/server)
│   ├── .chezmoiscripts/    # Install scripts
│   ├── dot_config/nix/     # Nix flake + home.nix
│   └── dot_*               # Dotfiles
└── docs/                   # Documentation
```

## Development

```bash
just lint     # Run shellcheck
just format   # Run shfmt
just check    # Check formatting

chezmoi apply --dry-run -v  # Preview changes
chezmoi diff                # Show differences
```

## Manual Setup

After `chezmoi apply`:

1. Edit `~/.gitconfig.local` with your name/email
2. Run `exec bash` after first Nix install
3. Log out/in for docker group

## Documentation

See [docs/](docs/) for detailed guides: manual setup, installed tools, keybindings.
