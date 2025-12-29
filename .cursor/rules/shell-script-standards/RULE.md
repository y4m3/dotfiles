---
description: "Coding standards and conventions for shell scripts in this repository. Applies to run_once scripts, helper scripts, tests, and bashrc.d modules."
globs:
  - "home/run_once_*.sh.tmpl"
  - "scripts/*.sh"
  - "tests/*.sh"
  - "home/dot_bashrc.d/*.sh"
---

# Shell Script Standards

## Shebang

**REQUIRED**: Use `#!/usr/bin/env bash` (not `#!/bin/bash`)

```bash
#!/usr/bin/env bash
```

**Rationale**: `env` ensures portability across different systems where bash may be installed in different locations.

## Error Handling

**REQUIRED**: Use `set -euo pipefail` at the start of all scripts

```bash
#!/usr/bin/env bash
set -euo pipefail
```

- `-e`: Exit immediately if a command exits with a non-zero status
- `-u`: Treat unset variables as an error
- `-o pipefail`: Return value of a pipeline is the status of the last command to exit with a non-zero status

**Exception**: Test scripts may temporarily disable these for specific assertions (e.g., `set +e` before timeout commands, then `set -e` after).

## APT Operations

**REQUIRED**: Use `DEBIAN_FRONTEND=noninteractive` for all APT operations

```bash
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y package-name
```

**Rationale**: Prevents interactive prompts in non-interactive environments (Docker, CI).

## Idempotency

**REQUIRED**: All `run_once_*` scripts MUST be idempotent

Check for existing installations before proceeding:

```bash
if command -v tool-name >/dev/null 2>&1; then
  echo "✓ tool-name already installed"
  exit 0
fi
```

Or check for specific files/directories:

```bash
if [ -f "$HOME/.local/bin/tool-name" ]; then
  echo "✓ tool-name already installed"
  exit 0
fi
```

## Log Messages

**REQUIRED**: Use consistent log message patterns

- Start of operation: `echo "==> Starting operation..."`
- Success: `echo "✓ Operation completed"`
- Error: `echo "Error: message" >&2`

**Example**:
```bash
echo "==> Installing tool-name..."
# ... installation steps ...
echo "✓ tool-name installed successfully"
```

## Comments

**REQUIRED**: All comments MUST be in English (no Japanese)

**REQUIRED**: Include a brief description at the top of each script

```bash
#!/usr/bin/env bash
# Install tool-name from official GitHub releases
# This script is idempotent and can be run multiple times safely
set -euo pipefail
```

## Code Formatting

**REQUIRED**: Follow `.editorconfig` settings for shell scripts

- Indent size: 2 spaces
- End of line: LF
- Max line length: 120 characters
- Use `shfmt` for formatting (see `make format`)

## Temporary Files

**REQUIRED**: Use `mktemp` and `trap` for cleanup

```bash
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
```

## Architecture Detection

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

## GitHub API Authentication

**REQUIRED**: Support authenticated GitHub API requests when available

```bash
# Use GitHub token if available (from gh auth token or GITHUB_TOKEN env var)
github_token=""
if command -v gh >/dev/null 2>&1 && gh auth token >/dev/null 2>&1; then
  github_token=$(gh auth token 2>/dev/null || echo "")
fi
if [ -z "$github_token" ] && [ -n "${GITHUB_TOKEN:-}" ]; then
  github_token="$GITHUB_TOKEN"
fi

if [ -n "$github_token" ]; then
  version=$(curl -fsSL -H "Authorization: token $github_token" https://api.github.com/repos/owner/repo/releases/latest | jq -r '.tag_name')
else
  version=$(curl -fsSL https://api.github.com/repos/owner/repo/releases/latest | jq -r '.tag_name')
fi
```

**Rationale**: Authenticated requests have a 5000/hour rate limit vs 60/hour for unauthenticated requests.

## Docker Skip Pattern

**OPTIONAL**: Skip installation in Docker containers when appropriate

```bash
# Skip in Docker containers (development images manage dependencies separately)
if [ -f /.dockerenv ]; then
  echo "==> Running in Docker, skipping installation"
  exit 0
fi
```

Use this pattern when:
- The tool is pre-installed in the Docker image
- The tool is not needed in the Docker test environment
- Installation would conflict with Docker-specific setup

## References

- [Configuration Guide](../docs/configuration.md) - Design principles and customization methods
- [EditorConfig](../.editorconfig) - Code formatting settings
- [Makefile](../Makefile) - `make format` for automatic formatting

