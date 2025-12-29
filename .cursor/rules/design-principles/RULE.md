---
description: "Core design principles for this dotfiles repository: non-destructive customization, modularization, idempotency, and reproducibility."
alwaysApply: true
---

# Design Principles

## Overview

This repository manages dotfiles with chezmoi. Host setup is the primary path; Docker is only for validation. All design decisions prioritize reproducibility, maintainability, and user customization.

## 1. Non-Destructive Customization

**Principle**: User-specific settings MUST NOT be overwritten by chezmoi.

**Implementation**:

- User-specific settings are written in `.bashrc.local`
- Managed as `create_.bashrc.local.tmpl` (created only on first apply)
- Not overwritten by chezmoi on subsequent applies
- Freely editable by users without risk of loss

**Example**:
```bash
# ~/.bashrc.local (user-editable, not managed by chezmoi)
export ENABLE_CD_LS=1           # Auto ls after cd
export FZF_DEFAULT_OPTS='...'   # fzf customization
alias mycommand='...'            # Personal aliases
```

**Files using this pattern**:
- `home/create_.bashrc.local.tmpl` - User bashrc customizations
- `home/create_.gitconfig.local.tmpl` - User git config
- `home/create_*.tmpl` - All "create-if-missing" templates

## 2. Modular bashrc

**Principle**: Settings are split into independent, manageable modules.

**Implementation**:

Settings are split and managed in `~/.bashrc.d/` directory:

- `10-user-preferences.sh`: User settings (locale, editor, etc.)
- `20-paths.sh`: PATH management
- `30-completion.sh`: Command completion
- `40-runtimes.sh`: Language runtime initialization (Rust, Node.js, etc.)
- `50-direnv.sh`: direnv hook integration
- `60-utils.sh`: Tool initialization and aliases

**Benefits**:
- Each file operates independently
- Can be disabled or customized as needed
- Easy to understand and maintain
- Clear separation of concerns

## 3. Idempotency

**Principle**: All `run_once_*` scripts MUST be idempotent (safe to run multiple times).

**Requirements**:

- Detect existing installations and avoid re-execution
- Use `set -euo pipefail` for strict error checking
- Provide clear log messages (`==> Starting`, `✓ Completed`)
- APT operations use `DEBIAN_FRONTEND=noninteractive` for non-interactive mode

**Example**:
```bash
#!/usr/bin/env bash
set -euo pipefail

if command -v tool-name >/dev/null 2>&1; then
  echo "✓ tool-name already installed"
  exit 0
fi

echo "==> Installing tool-name..."
# ... installation steps ...
echo "✓ tool-name installed successfully"
```

## 4. Reproducibility

**Principle**: Host application is the primary path; Docker is for validation only.

**Workflow**:

1. **Host setup (primary)**:
   ```bash
   sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
   ```

2. **Docker validation (optional)**:
   ```bash
   make dev    # Interactive shell for testing
   make test   # Change detection test
   make test-all  # Full test suite
   ```

**Key Points**:
- Docker environment is throwaway and for validation only
- Host system is the source of truth
- All changes should be tested in Docker before applying to host

## 5. Sequential Execution

**Principle**: `run_once_*.sh.tmpl` scripts are executed in numerical order.

**Numbering System**:

- `0xx`: Foundation (prerequisites, chezmoi)
- `1xx`: Language runtimes (Rust, Node.js, Python/uv)
- `2xx`: CLI/Shell tools (fzf, cargo tools, direnv, shellcheck, zellij, yq, btop, yazi)
- `3xx`: Dev tools (gh, ghq, delta, lazygit, lazydocker)

**Example**:
- `run_once_000-prerequisites.sh.tmpl` - Base system tools
- `run_once_100-runtimes-rust.sh.tmpl` - Rust installation
- `run_once_210-shell-cargo-tools.sh.tmpl` - Cargo-installed tools

**Rationale**: Ensures dependencies are installed before dependent tools.

## 6. Configuration File Management

**Principle**: Configuration files are managed by chezmoi and generated from templates.

**Patterns**:

- `home/dot_*` → `~/.file` (overwrites existing files)
- `home/create_*` → `~/.file` (creates only if missing)
- `home/dot_config/*` → `~/.config/*` (tool-specific configs)

**Examples**:
- `home/dot_bashrc.tmpl` → `~/.bashrc`
- `home/create_.bashrc.local.tmpl` → `~/.bashrc.local` (if missing)
- `home/dot_config/starship.toml.tmpl` → `~/.config/starship.toml`

## 7. PATH Management

**Principle**: PATH is built with clear priority order.

**Priority Order**:

1. `~/.local/bin` (highest priority - user-installed tools)
2. `~/.cargo/bin` (Rust tools)
3. `~/go/bin` (Go tools, ghq, etc.)
4. System default PATH

**Implementation**: Managed in `home/dot_bashrc.d/20-paths.sh` with idempotent path prepending.

## References

- [Configuration Guide](../docs/configuration.md) - Detailed configuration policy and customization methods
- [Shell Script Standards](./shell-script-standards/RULE.md) - Coding conventions for scripts
- [Run Once Scripts](./run-once-scripts/RULE.md) - Guidelines for run_once scripts

