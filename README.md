# chezmoi-first setup guide

This repository manages dotfiles with [chezmoi](https://www.chezmoi.io/#what-does-chezmoi-do). Host setup is the primary path; Docker is only for validation.

### Requirements

- curl, git

```bash
sudo apt update; sudo apt install -y curl git
```

## Quick start (host)

1) Install chezmoi and apply this repo:
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply y4m3
```

2) Update later:
```bash
chezmoi update
```
(`chezmoi pull && chezmoi apply` is equivalent)


## What chezmoi manages here

- `home/` dotfiles (`dot_*`, `dot_*/*.sh`, `create_*` templates)
- `run_once_*.sh.tmpl`: first-run install scripts (numbered by category)
- Themed configs (delta, lazygit, zellij, yazi)

## Run-once numbering (brief)

- 0xx: Foundation (prerequisites)
- 1xx: Language runtimes (e.g., uv)
- 2xx: CLI/Shell (direnv, yq, btop, yazi, zellij)
- 3xx: Dev tools (delta, lazygit, lazydocker)

## Optional: Docker for testing

Use only when you need a throwaway validation environment. For detailed testing information, see [Testing Guide](docs/testing-guide.md).

```bash
make build              # Build Docker image
make dev                # chezmoi apply in container + login shell
make test               # Change detection test (runs tests for changed files only)
make test-all           # Run all tests (creates snapshot on success)
make test-all BASELINE=1 # Run all tests and save baseline
make clean              # Remove persistent volumes
make clean REBUILD=1    # Remove volumes and rebuild environment
make reset              # Reset manual installations, return to state A
make lint               # shellcheck in lint image
make format             # shfmt in lint image
```

### Environment Management Workflow

This repository supports efficient tool testing with snapshot-based environment management:

1. **Initial setup (State A)**: Run `make test-all` to build environment A and create a snapshot
2. **Try new tools (State B = A + X)**: Use `make dev` to enter container, manually install tools
3. **Continue testing**: Run `make dev` again to maintain state B
4. **Reset to State A**: Run `make reset` to remove manually installed tools
5. **Complete reset**: Run `make clean REBUILD=1` to rebuild everything from scratch

The snapshot system automatically tracks run_once-installed tools, so you don't need to maintain tool lists manually.

## Directory quick reference

- `home/`: dotfiles sources (e.g., dot_bashrc, dot_bashrc.d/*)
- `tests/`: tool smoke tests
- `docs/`: policy and templates (e.g., docs/templates/envrc-examples.md, docs/testing-guide.md)
- `Dockerfile`, `Makefile`: container validation & automation

## Verification

For comprehensive verification of installation and configuration, see [docs/testing-guide.md](docs/testing-guide.md).

## Tips

- `create_*.tmpl` are "create-if-missing" templates; existing files are preserved.
- Host application is the source of truth; Docker is for safe verification.

### Main Targets

- **`make dev`**: Launch interactive shell with chezmoi applied (most common for development)
- **`make test`**: Change detection test - runs tests for changed files only (default, frequently used)
- **`make test-all`**: Runs all tests and creates environment snapshot on success
- **`make test-all BASELINE=1`**: Runs all tests and saves results as baseline for comparison
- **`make clean`**: Remove persistent volumes (next `make dev` or `make test` will rebuild)
- **`make clean REBUILD=1`**: Remove volumes and rebuild environment (complete reset)
- **`make reset`**: Remove manually installed tools by comparing with snapshot (preserves chezmoi state)

For detailed testing workflow and test types, see [Testing Guide](docs/testing-guide.md).

## Installed Tools

- **Rust Ecosystem**: bat, eza, fd-find, ripgrep, starship, zoxide
- **Node.js**: NodeSource 22.x
- **GitHub Tools**: gh (GitHub CLI), ghq (repository manager)
- **Others**: fzf (fuzzy finder)

## Documentation

For detailed usage and customization methods, refer to:

- **[Configuration Guide](docs/configuration.md)** - Configuration policy and customization methods
- **[Post-Setup Tasks](docs/post-setup.md)** - Manual tasks after initial setup (fonts, etc.)
- **[Troubleshooting](docs/troubleshooting.md)** - Common issues and solutions
- **[Security Best Practices](docs/tools/security.md)** - Credential management and file permissions
- **Tool-specific details**:
  - [fzf](docs/tools/fzf.md) - Fuzzy finder
  - [Cargo Tools](docs/tools/cargo-tools.md) - bat, eza, fd, ripgrep, starship
  - [zoxide](docs/tools/zoxide.md) - Directory jumping
  - [GitHub Tools](docs/tools/github-tools.md) - gh, ghq
