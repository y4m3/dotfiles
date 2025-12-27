# chezmoi

chezmoi is a dotfiles manager written in Go. It manages dotfiles across multiple machines securely.

## Installation

This repository includes automated installation via `run_once_010-chezmoi.sh.tmpl`:

### Automatic Installation

chezmoi is automatically installed as part of the dotfiles initialization:

```bash
# On a new machine:
curl -fsSL https://get.chezmoi.io | bash
chezmoi init <your-repo-url>
chezmoi apply
```

The installer will:
- Detect your platform (macOS/Linux)
- Use Homebrew on macOS if available
- Use the official installer script on Linux
- Verify the installation and print the version

### Manual Installation

If you prefer to install manually:

#### macOS

```bash
brew install chezmoi
```

#### Linux (Debian/Ubuntu/Fedora/etc.)

```bash
curl -fsSL https://get.chezmoi.io | bash
```

#### Other Platforms

Visit [chezmoi.io](https://www.chezmoi.io/install/) for installation instructions.

## Configuration

This dotfiles repository is configured with chezmoi. Configuration files are stored in `home/` and are deployed to `$HOME` when you run `chezmoi apply`.

### key files

- `home/dot_bashrc` → `~/.bashrc`
- `home/dot_gitconfig` → `~/.gitconfig`
- `home/dot_tmux.conf` → `~/.tmux.conf`
- `home/dot_config/` → `~/.config/`
- `home/run_once_*.sh.tmpl` - Scripts that run once per machine (installers, initial setup, etc.)

## Common Commands

```bash
# Initialize chezmoi with this repository
chezmoi init https://github.com/y4m3/dotfiles.git

# Apply all dotfiles to your system
chezmoi apply

# See what changes would be applied (diff)
chezmoi diff

# Edit a dotfile
chezmoi edit ~/.bashrc

# Manage specific files
chezmoi add ~/.bashrc
chezmoi remove ~/.bashrc

# Check your system status
chezmoi status

# Update from the source repository
chezmoi update
```

## Testing

A comprehensive test suite is provided:

```bash
# Run just the chezmoi test
bash tests/chezmoi-test.sh

# Run all tests
make test
```

## Documentation

For more information, visit:
- [Official chezmoi documentation](https://www.chezmoi.io/)
- [chezmoi GitHub repository](https://github.com/twpayne/chezmoi)
