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
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply y4m3
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

Use only when you need a throwaway validation environment.

```bash
make build     # Build Docker image
make dev       # chezmoi apply in container + login shell
make test      # Run all tests
make lint      # shellcheck in lint image
make format    # shfmt in lint image
```
- Manual inside container: `bash scripts/apply-container.sh`
- Reset persistent volumes: `make clean-state`

## Directory quick reference

- `home/`: dotfiles sources (e.g., dot_bashrc, dot_bashrc.d/*)
- `tests/`: tool smoke tests
- `docs/`: policy and templates (e.g., docs/templates/envrc-examples.md)
- `Dockerfile`, `Makefile`: container validation & automation

## Tips

- `create_*.tmpl` are "create-if-missing" templates; existing files are preserved.
- Host application is the source of truth; Docker is for safe verification.

# Bash Configuration Testing Workflow for Ubuntu 24.04

This directory contains a minimal setup for testing chezmoi-managed bash configurations on Ubuntu 24.04 containers

## Usage

```bash
# Run Makefile commands on the host system (execute in this directory)
make build   # Build the Docker image
make shell   # Launch a shell session inside the container
make test    # Execute chezmoi apply followed by smoke tests (used for change verification)
```

### Simplified Application Inside Container

Once inside the container, run the following single command to execute both chezmoi init and apply operations together:

```bash
bash scripts/apply-container.sh
```

You can customize paths via arguments if needed (defaults: source=/workspace, destination=/root).

For manual execution, refer to the following commands:

```bash
docker build -t dotfiles-test:ubuntu24.04 .
docker run --rm -it -v "$(pwd):/workspace" -w /workspace dotfiles-test:ubuntu24.04 bash

chezmoi init \
 --source=/workspace \
 --destination=/root

# chezmoi setup (host-first)

Minimal steps on your host (Linux/WSL/macOS). Docker is only for validation.

## Quick start (host)

Install and apply (replace `$GITHUB_USERNAME`):
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```
Update later:
```bash
chezmoi update
```

## Managed scope

- `home/`: dotfiles (`dot_*`, `create_*`)
- `run_once_*.sh.tmpl`: one-time installers (numbered)
- themed configs: delta, lazygit, zellij, yazi

Run-once numbering: 0xx=base, 1xx=lang, 2xx=CLI, 3xx=dev tools.

## Docker (optional)

```bash
make build   # build image
make dev     # apply + login shell
make test    # run tests
make lint    # shellcheck
make format  # shfmt
```
Manual: `bash scripts/apply-container.sh`; reset volumes: `make clean-state`.

## Notes
- `create_*.tmpl` only creates missing files.
- Host setup is the source of truth; use Docker just to verify.
- `clean-state`: Clear Docker persistent volumes (re-run run_once scripts)

## Installed Tools

- **Rust Ecosystem**: bat, eza, fd-find, ripgrep, starship, zoxide
- **Node.js**: NodeSource 22.x
- **GitHub Tools**: gh (GitHub CLI), ghq (repository manager)
- **Others**: fzf (fuzzy finder)

## Documentation

For detailed usage and customization methods, refer to:

- **[Configuration Guide](docs/configuration.md)** - Configuration policy and customization methods
- **[Troubleshooting](docs/troubleshooting.md)** - Common issues and solutions
- **Tool-specific details**:
  - [fzf](docs/tools/fzf.md) - Fuzzy finder
  - [Cargo Tools](docs/tools/cargo-tools.md) - bat, eza, fd, ripgrep, starship
  - [zoxide](docs/tools/zoxide.md) - Directory jumping
  - [GitHub Tools](docs/tools/github-tools.md) - gh, ghq
