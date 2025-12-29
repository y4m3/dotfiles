---
description: "Guidelines for creating and maintaining run_once_*.sh.tmpl scripts. Defines numbering system, required patterns, and best practices."
globs:
  - "home/run_once_*.sh.tmpl"
---

# Run Once Scripts

## Overview

`run_once_*.sh.tmpl` scripts are executed by chezmoi only once (or when their content changes). They handle tool installation, initial setup, and one-time configuration.

## Numbering System

**REQUIRED**: Follow the numbering convention for execution order

Scripts are executed in lexicographic (numerical) order:

- **`0xx`**: Foundation (prerequisites, base tools)
  - `000`: Prerequisites (build tools, git, curl, jq, tmux)
  - `010`: chezmoi installation

- **`1xx`**: Language runtimes
  - `100`: Rust (rustup, cargo)
  - `110`: Node.js
  - `120`: Python/uv

- **`2xx`**: CLI/Shell tools
  - `200`: fzf (fuzzy finder)
  - `210`: Cargo-installed tools (bat, eza, fd, ripgrep, starship, zoxide)
  - `240`: direnv
  - `250`: shellcheck, shfmt
  - `265`: zellij (terminal multiplexer)
  - `275`: yq (YAML processor)
  - `280`: btop (system monitor)
  - `285`: yazi (file manager)

- **`3xx`**: Dev tools
  - `300`: gh (GitHub CLI)
  - `310`: ghq (repository manager)
  - `320`: delta (git pager)
  - `330`: lazygit (Git TUI)
  - `340`: lazydocker (Docker TUI)

**Rationale**: Ensures dependencies are installed before dependent tools (e.g., Rust before cargo tools).

## Required Patterns

### 1. Shebang and Error Handling

**REQUIRED**: Start with shebang and strict error handling

```bash
#!/usr/bin/env bash
# Brief description of what this script does
set -euo pipefail
```

### 2. Idempotency Check

**REQUIRED**: Check for existing installation before proceeding

```bash
if command -v tool-name >/dev/null 2>&1; then
  echo "✓ tool-name already installed ($(tool-name --version))"
  exit 0
fi
```

Or for file-based installations:

```bash
if [ -f "$HOME/.local/bin/tool-name" ]; then
  echo "✓ tool-name already installed"
  exit 0
fi
```

### 3. Log Messages

**REQUIRED**: Use consistent log message patterns

```bash
echo "==> Installing tool-name..."
# ... installation steps ...
echo "✓ tool-name installed successfully"
```

### 4. Docker Skip (When Appropriate)

**OPTIONAL**: Skip installation in Docker containers when tool is pre-installed

```bash
# Skip in Docker containers (development images manage dependencies separately)
if [ -f /.dockerenv ]; then
  echo "==> Running in Docker, skipping installation"
  exit 0
fi
```

**Use when**:
- Tool is pre-installed in Dockerfile
- Tool is not needed in Docker test environment
- Installation would conflict with Docker-specific setup

### 5. Architecture Detection

**REQUIRED**: Handle multiple architectures when downloading binaries

```bash
case "$(uname -m)" in
  x86_64 | amd64) arch="amd64" ;;
  aarch64 | arm64) arch="arm64" ;;
  *)
    echo "Unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac
```

### 6. GitHub API Authentication

**REQUIRED**: Support authenticated GitHub API requests when available

```bash
# Use GitHub token if available (from gh auth token or GITHUB_TOKEN env var)
# This increases rate limit from 60/hour (unauthenticated) to 5000/hour (authenticated)
github_token=""
if command -v gh >/dev/null 2>&1 && gh auth token >/dev/null 2>&1; then
  github_token=$(gh auth token 2>/dev/null || echo "")
fi
if [ -z "$github_token" ] && [ -n "${GITHUB_TOKEN:-}" ]; then
  github_token="$GITHUB_TOKEN"
fi

if [ -n "$github_token" ]; then
  version=$(curl -fsSL -H "Authorization: token $github_token" \
    https://api.github.com/repos/owner/repo/releases/latest | jq -r '.tag_name')
else
  version=$(curl -fsSL \
    https://api.github.com/repos/owner/repo/releases/latest | jq -r '.tag_name')
fi
```

**Rationale**: Authenticated requests have 5000/hour rate limit vs 60/hour for unauthenticated.

### 7. Temporary File Cleanup

**REQUIRED**: Use `mktemp` and `trap` for cleanup

```bash
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Use $tmpdir for downloads/extractions
curl -fsSL "$url" -o "$tmpdir/file.tar.gz"
tar -xzf "$tmpdir/file.tar.gz" -C "$tmpdir/extract"
```

### 8. Installation Directory

**REQUIRED**: Use `$HOME/.local/bin` for user-installed binaries

```bash
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"
install -m 0755 "$binary_path" "$INSTALL_DIR/tool-name"
```

### 9. APT Operations

**REQUIRED**: Use `DEBIAN_FRONTEND=noninteractive` for all APT operations

```bash
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y package-name
```

## Example Template

Complete example following all patterns:

```bash
#!/usr/bin/env bash
# Install tool-name from official GitHub releases
set -euo pipefail

# Skip in Docker containers if appropriate
if [ -f /.dockerenv ]; then
  echo "==> Running in Docker, skipping installation"
  exit 0
fi

# Idempotency check
if command -v tool-name >/dev/null 2>&1; then
  echo "✓ tool-name already installed ($(tool-name --version))"
  exit 0
fi

INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

# Architecture detection
case "$(uname -m)" in
  x86_64 | amd64) arch="amd64" ;;
  aarch64 | arm64) arch="arm64" ;;
  *)
    echo "Unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

# GitHub API authentication
github_token=""
if command -v gh >/dev/null 2>&1 && gh auth token >/dev/null 2>&1; then
  github_token=$(gh auth token 2>/dev/null || echo "")
fi
if [ -z "$github_token" ] && [ -n "${GITHUB_TOKEN:-}" ]; then
  github_token="$GITHUB_TOKEN"
fi

# Resolve version
if [ -n "$github_token" ]; then
  version=$(curl -fsSL -H "Authorization: token $github_token" \
    https://api.github.com/repos/owner/repo/releases/latest | jq -r '.tag_name')
else
  version=$(curl -fsSL \
    https://api.github.com/repos/owner/repo/releases/latest | jq -r '.tag_name')
fi

if [ -z "$version" ] || [ "$version" = "null" ]; then
  echo "Failed to resolve tool-name version" >&2
  exit 1
fi

# Download and install
echo "==> Installing tool-name ${version}..."
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

url="https://github.com/owner/repo/releases/download/${version}/tool-name-${arch}.tar.gz"
curl -fsSL "$url" -o "$tmpdir/tool-name.tar.gz"
tar -xzf "$tmpdir/tool-name.tar.gz" -C "$tmpdir/extract"

binary_path=$(find "$tmpdir/extract" -maxdepth 2 -type f -name tool-name | head -n 1)
if [ -z "$binary_path" ]; then
  echo "tool-name binary not found in archive" >&2
  exit 1
fi

install -m 0755 "$binary_path" "$INSTALL_DIR/tool-name"

echo "✓ tool-name installed successfully"
echo "  Version: $("$INSTALL_DIR/tool-name" --version)"
```

## Version Override

**OPTIONAL**: Support version override via environment variable

```bash
if [ -n "${TOOL_NAME_VERSION:-}" ]; then
  version="$TOOL_NAME_VERSION"
else
  # Resolve latest version from GitHub API
  # ...
fi
```

**Use case**: Pin specific versions for testing or compatibility.

## Error Handling

**REQUIRED**: Provide clear error messages

```bash
if [ -z "$version" ] || [ "$version" = "null" ]; then
  echo "Failed to resolve tool-name version" >&2
  exit 1
fi

if [ ! -f "$binary_path" ]; then
  echo "tool-name binary not found in archive" >&2
  exit 1
fi
```

## References

- [Shell Script Standards](./shell-script-standards/RULE.md) - Coding conventions
- [Design Principles](./design-principles/RULE.md) - Idempotency and reproducibility
- [Docker Workflow](./docker-workflow/RULE.md) - Docker testing patterns

