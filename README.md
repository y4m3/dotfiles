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

chezmoi apply \
 --source=/workspace \
 --destination=/root \
 --force

chezmoi diff
```

## Directory Structure

- Dockerfile: Minimal Ubuntu 24.04 image with chezmoi (includes bash-completion, locales, and color terminal support)
- home/: Bash configuration files (`dot_bashrc`, `dot_bashrc.d/`, `dot_bash_prompt.d/`)

### File Naming Convention

- chezmoi source files: `home/dot_*` → deployed as: `~/.*` (after applying)
- Example: `home/dot_bashrc.d` → `~/.bashrc.d`

### Chezmoi: create_ templates

- Use `create_`-prefixed source files when you want chezmoi to create a file only if it does not already exist on the destination. This is the recommended, official way to provide "create-if-missing" defaults (for example, `home/create_.bashrc.local.tmpl`).
- Behaviour: on `chezmoi apply`, files named `create_<name>` are created at the destination path `<name>` only when the destination file is absent. After creation the file is managed as a normal, user-editable file.
- Prefer `create_` over ad-hoc run-once scripts for simple create-if-missing semantics; use CI/container pipeline scripts for more complex, idempotent initialization steps.

(y4m3 × GitHub Copilot)
