# Test Suite

This document explains the test suite structure and execution methods.

## Directory Structure

```
tests/
├── bash-config-test.sh         # bash configuration validation
├── cargo-test.sh               # Rust/Cargo installation test
├── github-tools-test.sh        # gh, ghq availability test
├── node-test.sh                # Node.js installation test
├── zoxide-test.sh              # zoxide functionality test
├── lib/
│   └── helpers.sh              # Common test functions and utilities
├── README.md                   # This file
└── integration-test.sh          # (Future) Integration tests
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
# (Future) Individual test targets may be added to Makefile
make test-cargo
make test-bash
make test
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

## Future Tests

- [ ] `integration-test.sh`: Integration tests across multiple tools
- [ ] `performance-test.sh`: Startup time, PATH building performance
- [ ] `security-test.sh`: File permission checks, secure configuration verification
