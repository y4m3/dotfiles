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

### run_once Scripts: Numbering Convention

run_once scripts use 3-digit numbers (000-999) to manage categories and execution order.

#### Category System (Hundreds Place)

- **0XX: Foundation & System** - System foundation, OS base packages, system configuration
- **1XX: Language Runtimes** - Programming language runtime environments (Rust, Node.js, Python, Go, etc.)
- **2XX: CLI Tools & Utilities** - Command-line tools (fzf, cargo tools, shell extensions, etc.)
- **3XX: Development Tools** - Development environment, version control (Git-related, editors, linters, etc.)
- **4XX: Infrastructure & Cloud** - Infrastructure and cloud tools (Docker, Kubernetes, AWS/GCP/Azure CLI, etc.)
- **5XX: Networking & Security** - Network and security tools (HTTP clients, DNS, VPN, etc.)
- **6XX: Data & Database** - Data processing and database-related (DB clients, data processing tools, etc.)
- **7XX: Monitoring & Observability** - Monitoring and observability tools
- **8XX: Reserved** - Reserved for future major categories
- **9XX: User-specific & Experimental** - User-specific and experimental tools

When adding new tools, use an available number in the appropriate category.

(y4m3 × GitHub Copilot)

## Quickstart
- Host: `make build`, `make dev` (launch login shell in container), `make test` (automated tests)
- Inside container: Run `bash scripts/apply-container.sh` to execute `chezmoi init/apply` together

## Make Targets
- `build`: Build Docker image
- `shell`: Launch bash shell in clean container
- `dev`: Apply dotfiles and drop into login shell (for manual testing)
- `test`: Run all tests (bash/cargo/github/node/zoxide)
- `test-shell`: Launch interactive shell with tests pre-applied (for individual test execution)
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
