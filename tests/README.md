# Test Suite

This document explains the test suite structure and execution methods.

## Directory Structure

```
tests/
├── *-test.sh                   # Individual test files for each tool/component
├── lib/
│   └── helpers.sh              # Common test functions and utilities
└── README.md                   # This file
```

## Test Execution Methods

### 1. Running Single Tests

```bash
# Cargo test only
bash tests/cargo-test.sh

# Or from within container
docker run --rm -it -v "$(pwd):/workspace" dotfiles-test:ubuntu24.04 bash
bash scripts/apply-container.sh
bash tests/cargo-test.sh
```

```bash
# bash configuration test only
bash tests/bash-config-test.sh
```

### 2. Running All Tests

```bash
for test in tests/*-test.sh; do bash "$test"; done
```

### 3. Running Tests from Host (Makefile)

```bash
# Run change detection test (runs tests for changed files only)
make test

# Run all tests
make test-all
```

## Common Test Functions (helpers.sh)

`tests/lib/helpers.sh` defines common functions:

| Function | Purpose | Usage Example |
|----------|---------|---------------|
| `pass "message"` | Record test success | `pass "cargo installed"` |
| `fail "message"` | End script with test failure | `fail "rustc not found"` |
| `warn "message"` | Non-fatal warning | `warn "Version outdated"` |
| `assert_command "cmd" ["desc"]` | Assert command success | `assert_command "rustc --version"` |
| `assert_exists "path" ["desc"]` | Assert file/dir existence | `assert_exists "$HOME/.cargo/bin/rustc"` |
| `assert_not_empty "var" ["desc"]` | Assert variable not empty | `assert_not_empty "$CARGO_HOME"` |
| `print_summary` | Display test result summary | `print_summary` |

## Guidelines for Adding Tests

When adding new test scripts:

1. **Naming Convention**: Use `*-test.sh` suffix (e.g., `docker-test.sh`)
2. **Load helpers.sh**:
   ```bash
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   source "$SCRIPT_DIR/lib/helpers.sh"
   ```

3. **Use helper functions**:
   ```bash
   # Test content
   assert_command "docker --version" "Docker installed"
   assert_exists "/usr/bin/docker" "Docker binary exists"
   ```

4. **Optional summary**:
   ```bash
   # At end of script
   print_summary
   ```

5. **Exit handling**: `fail()` calls `exit 1`, so errors automatically terminate the script

## Test Design Principles

- **Independent**: Each test script runs independently
- **Concise**: 1 test script = 1 feature/area tested
- **Idempotent**: Can run multiple times without side effects
- **Fast**: Minimize execution time (especially important for CI)

## Test Standards

For personal chezmoi dotfiles management, we use a 3-level testing standard to balance thoroughness with maintainability:

### Level 1: Basic Verification (Minimum)

**Required for all tools:**
- Installation check: `assert_executable "tool"`
- Version check: `assert_command "tool --version"`
- Config file existence check (if managed by chezmoi): `assert_file_exists "$HOME/.config/tool/config"`

**Target tools**: Simple tools (btop, lazygit, lazydocker, yq, chezmoi, prerequisites, node, uv, github-tools, yazi, etc.)

**Example:**
```bash
assert_executable "btop" "btop installed"
assert_command "btop --version" "btop version prints"
assert_file_exists "$HOME/.config/btop/btop.conf" "btop config file deployed"
```

### Level 2: Functionality Verification (Recommended)

**Level 1 + add:**
- Basic functionality test (one): Test one main feature of the tool
- Config file validation (if managed by chezmoi): Verify config file is valid

**Target tools**: Tools where config files are important (zellij, starship, direnv, shellcheck, fzf, zoxide, bash-config, etc.)

**Note**: Each tool should have its own test file. For example:
- `tests/zellij-test.sh` - Tests zellij installation and config validation
- `tests/starship-test.sh` - Tests starship installation and config validation
- `tests/bash-config-test.sh` - Tests bash configuration files only (not individual tools)

**Example:**
```bash
# Level 1 tests
assert_executable "zellij" "zellij installed"
assert_command "zellij --version" "zellij version prints"
assert_file_exists "$HOME/.config/zellij/config.kdl" "zellij config file exists"

# Level 2: Config validation
zellij setup --check < /dev/null && pass "zellij config syntax is valid" || fail "zellij config has errors"
```

### Level 3: Detailed Verification (Only when needed)

**Level 2 + add:**
- Integration test (e.g., git integration)
- Error handling test (verify it doesn't crash)

**Target tools**: Tools requiring complex integration (delta, etc.)

**Example:**
```bash
# Level 1 & 2 tests
# ...

# Level 3: Integration test
git init -q
echo "test" > file.txt
git add file.txt
git commit -q -m "test"
assert_command "git diff | delta --color-only" "delta works with git"
```

### Tests to Exclude

For personal environments, the following tests are excessive:
- Multiple functionality tests (one is enough)
- Detailed error handling tests (only verify it doesn't crash)
- Project creation/build tests (except for development environment tools)
- Multiple edge case tests

### Guidelines for Adding New Tools

When adding a new tool:
1. Start with Level 1 (basic verification)
2. Expand to Level 2 if config files are important
3. Expand to Level 3 only if special integration is needed

This keeps test maintenance overhead minimal while ensuring necessary verification.

## Test Templates

### Level 1 Template

```bash
#!/usr/bin/env bash
# Test [tool name] installation
# Usage: bash tests/[tool]-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing [tool name]"
echo "=========================================="

# Ensure PATH includes tool location
case ":$PATH:" in
  *":$HOME/.local/bin:") : ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

# Level 1: Basic verification
assert_executable "[tool]" "[tool] installed"
assert_command "[tool] --version" "[tool] version prints"

# Config file check (if managed by chezmoi)
assert_file_exists "$HOME/.config/[tool]/config" "[tool] config file deployed"

print_summary
```

### Level 2 Template

```bash
#!/usr/bin/env bash
# Test [tool name] installation and functionality
# Usage: bash tests/[tool]-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing [tool name]"
echo "=========================================="

# Ensure PATH includes tool location
case ":$PATH:" in
  *":$HOME/.local/bin:") : ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

# Level 1: Basic verification
assert_executable "[tool]" "[tool] installed"
assert_command "[tool] --version" "[tool] version prints"
assert_file_exists "$HOME/.config/[tool]/config" "[tool] config file exists"

# Level 2: Config validation
# Validate config using tool's built-in validation
if command -v "[tool]" >/dev/null 2>&1; then
  if [tool] --check-config 2>&1; then
    pass "[tool] config is valid"
  else
    fail "[tool] config has errors"
  fi
fi

# Level 2: Basic functionality test (one main feature)
# Example: Test that tool can perform its main function
assert_command "[tool] [basic-operation]" "[tool] can perform basic operation"

print_summary
```

### Level 3 Template

```bash
#!/usr/bin/env bash
# Test [tool name] installation, functionality, and integration
# Usage: bash tests/[tool]-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing [tool name]"
echo "=========================================="

# Ensure PATH includes tool location
case ":$PATH:" in
  *":$HOME/.local/bin:") : ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

# Level 1: Basic verification
assert_executable "[tool]" "[tool] installed"
assert_command "[tool] --version" "[tool] version prints"

# Level 2: Config validation (if applicable)
# ...

# Level 3: Integration test
# Example: Test integration with another tool
tmprepo="$(setup_tmpdir)"
trap 'rm -rf "$tmprepo"' EXIT
cd "$tmprepo"

# Setup integration environment
# ...

# Test integration
assert_command "[tool] [integration-operation]" "[tool] works with integration"

# Level 3: Error handling (verify it doesn't crash)
set +e
output=$([tool] --invalid-option 2>&1)
exit_code=$?
set -e
if [ $exit_code -gt 1 ]; then
  fail "[tool] crashed on invalid input (exit code: $exit_code)"
else
  pass "[tool] handles invalid input gracefully"
fi

print_summary
```

## Future Enhancements

Potential future test additions:
- Integration tests across multiple tools
- Performance tests (startup time, PATH building performance)
- Security tests (file permission checks, secure configuration verification)
