---
description: "Docker testing workflow and environment management patterns. Docker is for validation only; host application is the primary path."
globs:
  - "Dockerfile"
  - "Dockerfile.lint"
  - "Makefile"
  - "scripts/apply-container.sh"
---

# Docker Workflow

## Core Principle

**Docker is for validation only; host application is the primary path.**

The Docker environment is a throwaway testing environment. All changes should be tested in Docker before applying to the host system.

## Makefile Targets

### Development

**`make dev`**: Launch interactive shell with chezmoi applied

- Applies dotfiles configuration via `scripts/apply-container.sh`
- Drops into a login shell for manual testing
- Uses persistent volumes for state management
- Most common command for development

**Usage**:
```bash
make dev
# Interactive shell with all tools installed
```

### Testing

**`make test`**: Change detection test (default, frequently used)

- Detects changed files using `git diff`
- Maps changed files to relevant tests using `.test-mapping.json`
- Runs only the affected tests
- If no changes detected, runs all tests (safe default)

**Usage**:
```bash
make test
# Runs tests for changed files only
```

**`make test-all`**: Run all tests regardless of changes

- Runs `apply-container.sh` (checks/executes `run_once` scripts)
- Runs all test files (all `*-test.sh` files in `tests/` directory)
- Creates environment snapshot on success
- Execution time: 2-3 minutes (if already installed), 10-20 minutes (first time)

**Usage**:
```bash
make test-all
# Runs all tests and creates snapshot on success

make test-all BASELINE=1
# Runs all tests and saves results as baseline
```

### Environment Management

**`make clean`**: Remove persistent Docker volumes

- Removes `dotfiles-state`, `cargo-data`, `rustup-data`, `env-snapshot` volumes
- Next `make dev` or `make test` will rebuild the environment

**Usage**:
```bash
make clean
# Remove persistent volumes

make clean REBUILD=1
# Remove volumes and rebuild environment (complete reset)
```

**`make reset`**: Reset manual installations while preserving chezmoi state

- Compares current state with snapshot
- Removes manually installed tools
- Preserves chezmoi-managed state

**Usage**:
```bash
make reset
# Remove manually installed tools, return to state A
```

## Environment Management Workflow

This repository supports efficient tool testing with snapshot-based environment management:

1. **Initial setup (State A)**: Run `make test-all` to build environment A and create a snapshot
2. **Try new tools (State B = A + X)**: Use `make dev` to enter container, manually install tools
3. **Continue testing**: Run `make dev` again to maintain state B
4. **Reset to State A**: Run `make reset` to remove manually installed tools
5. **Complete reset**: Run `make clean REBUILD=1` to rebuild everything from scratch

The snapshot system automatically tracks run_once-installed tools, so you don't need to maintain tool lists manually.

## Persistent Volumes

**Purpose**: Maintain state across container runs to avoid re-installing tools.

**Volumes**:
- `dotfiles-state`: chezmoi state (tracks executed `run_once` scripts)
- `cargo-data`: Cargo cache and installed binaries
- `rustup-data`: Rustup data
- `env-snapshot`: Environment snapshots for reset functionality
- `gh-config`: GitHub CLI config (mounted read-only from host if available)

**Benefits**:
- 2nd run onwards: Fast startup (seconds instead of minutes)
- Development cycle: Test new `run_once` scripts without rebuilding everything
- State preservation: Tools remain installed across container restarts

## Dockerfile Principles

**Minimal base image**: Dockerfile installs only essential tools

- Essential tools: `curl`, `git`, `bash-completion`, `locales`, `tzdata`
- Pre-installed: `chezmoi` (only tool pre-installed)
- Other tools: Installed via `run_once_*` scripts (same as host)

**Rationale**:
- Maintainability: Single source of truth (no Dockerfile/run_once duplication)
- Consistency: Host and Docker use same installation scripts
- Extensibility: Add new tools without rebuilding Docker image
- Debuggability: Clear failure points (which `run_once` script failed)

## apply-container.sh

**Purpose**: Apply chezmoi configuration within Docker container.

**Responsibilities**:
- Apply dotfiles configuration with retry logic for lock contention
- Ensure PATH is set correctly for installed tools
- chezmoi automatically executes `run_once_*.sh.tmpl` scripts during `chezmoi apply`

**Key Features**:
- Retry logic for chezmoi lock contention
- PATH setup: Ensures `~/.local/bin` and `~/.cargo/bin` are in PATH
- chezmoi handles `run_once` script execution automatically using SHA256 hash-based state tracking

## GitHub API Authentication

**Automatic detection**: Makefile detects `gh` CLI login on host and passes `GITHUB_TOKEN` to containers.

**Benefits**:
- Authenticated requests: 5000/hour vs 60/hour unauthenticated
- Automatic: No manual token management needed
- Fallback: Falls back to unauthenticated if `gh` not available

**Implementation**:
```makefile
GITHUB_TOKEN := $(shell command -v gh >/dev/null 2>&1 && gh auth token 2>/dev/null || echo "")
DOCKER_RUN_BASE := docker run --rm ... $(if $(GITHUB_TOKEN),-e GITHUB_TOKEN="$(GITHUB_TOKEN)",)
```

## References

- [Testing Guide](../docs/testing-guide.md) - Detailed testing workflow and test types
- [README](../README.md) - Quick start and main targets
- [Design Principles](./design-principles/RULE.md) - Core design principles

