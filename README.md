# chezmoi-first setup guide

Dotfiles managed with [chezmoi](https://www.chezmoi.io/) + [Nix Home Manager](https://nix-community.github.io/home-manager/).

## Requirements

### Linux/WSL
- Ubuntu 24.04+ (WSL2 supported)
  - curl, git

### macOS
- macOS 14+ (Apple Silicon / arm64)
- curl, git

### Windows
- Windows 10/11
- PowerShell 5.1+
- winget (App Installer)

## Quick Start

### Linux/WSL

```bash
# 1. Bootstrap
curl -fsLS https://raw.githubusercontent.com/y4m3/dotfiles/main/install.sh | sh

# 2. Restart shell after Nix install
exec bash

# 3. Apply dotfiles (run in new shell)
chezmoi apply

# 4. Update later
chezmoi update
```

### Windows

```powershell
# 1. Bootstrap (one-liner)
irm https://raw.githubusercontent.com/y4m3/dotfiles/main/install.ps1 | iex

# Or with specific branch
$env:DOTFILES_BRANCH = "feature/xxx"; irm https://raw.githubusercontent.com/y4m3/dotfiles/main/install.ps1 | iex

# 2. Update later
chezmoi update
```

### macOS

```bash
# 1. Bootstrap
curl -fsLS https://raw.githubusercontent.com/y4m3/dotfiles/main/install.sh | sh

# 2. Apply dotfiles
chezmoi apply

# 3. Start a new shell session (required after first Nix install), then apply again
exec zsh
chezmoi apply

# 4. Update later
chezmoi update
```

### Windows (with private apps)

Private apps include: LibreWolf, Brave, Proton suite, Linear, Todoist, Zotero (platform-specific subset).

```powershell
# Set environment variable before init
$env:DOTFILES_INSTALL_PRIVATE_APPS = "true"

# Run init to regenerate config, then apply
chezmoi init
chezmoi apply

# To permanently enable (persists across sessions)
[Environment]::SetEnvironmentVariable("DOTFILES_INSTALL_PRIVATE_APPS", "true", "User")
```

## Features

- **Tokyo Night theme** unified across Neovim, tmux, WezTerm, and Zellij
- **tmux-sessionizer**: Fuzzy project/session switching with `prefix+F`
- **Unified keybindings**: Consistent h/j/k/l navigation across all terminal tools
- **Modular configs**: tmux, Neovim plugins organized for maintainability

## Architecture

- **Nix Home Manager**: 25+ CLI tools via `~/.config/nix/home.nix`
- **chezmoi**: Dotfiles + install scripts

## Directory Structure

```
.
├── install.sh              # Bootstrap script (Linux/WSL)
├── install.ps1             # Bootstrap script (Windows)
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
2. Run `exec bash` (Linux/WSL) or `exec zsh` (macOS) after first Nix install
3. Log out/in for docker group

## Pre-Production Checklist (macOS)

1. Local validation passes (`bash -n`, `shellcheck`, `chezmoi apply --dry-run -v`)
2. `nix --version` and `home-manager --version` succeed
3. `echo "$SHELL"` is `/bin/zsh` on macOS
4. GUI apps are installed from Brewfile and Rancher Desktop runs (`docker version`)

## Documentation

See [docs/](docs/) for detailed guides: manual setup, installed tools, keybindings.
