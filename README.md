# chezmoi-first setup guide

Dotfiles managed with [chezmoi](https://www.chezmoi.io/) + [Nix Home Manager](https://nix-community.github.io/home-manager/).

## Requirements

### Linux/WSL
- Ubuntu 24.04+ (WSL2 supported)
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

### Windows (with private apps)

Private apps include: LibreWolf, Brave, Proton suite, Linear, Todoist, Zotero.

```powershell
# Set environment variable before init
$env:DOTFILES_INSTALL_PRIVATE_APPS = "true"

# Run init to regenerate config, then apply
chezmoi init
chezmoi apply

# To permanently enable (persists across sessions)
[Environment]::SetEnvironmentVariable("DOTFILES_INSTALL_PRIVATE_APPS", "true", "User")
```

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
2. Run `exec bash` after first Nix install
3. Log out/in for docker group

## Documentation

See [docs/](docs/) for detailed guides: manual setup, installed tools, keybindings.
