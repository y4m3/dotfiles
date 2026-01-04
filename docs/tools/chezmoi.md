# chezmoi

chezmoi is a dotfiles manager written in Go. It manages dotfiles across multiple machines securely.

## Installation

This repository includes automated installation via `run_onchange_client_ubuntu_010-chezmoi.sh.tmpl`.

For installation instructions, see the [official chezmoi installation guide](https://www.chezmoi.io/install/).

## Configuration

This dotfiles repository is configured with chezmoi. Configuration files are stored in `home/` and are deployed to `$HOME` when you run `chezmoi apply`.

### key files

- `home/dot_bashrc` → `~/.bashrc`
- `home/dot_gitconfig` → `~/.gitconfig`
- `home/dot_tmux.conf` → `~/.tmux.conf`
- `home/dot_config/` → `~/.config/`
- `home/.chezmoiscripts/run_onchange_*.sh.tmpl` - Install scripts (re-run when content changes)
- `home/.chezmoi.toml.tmpl` - Profile variable (client/server)

## Common Commands

For all chezmoi commands and usage, refer to the [official chezmoi documentation](https://www.chezmoi.io/user-guide/command-overview/).

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
