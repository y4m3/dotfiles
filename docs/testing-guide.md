# Testing Guide

This guide provides comprehensive documentation of the testing system for this dotfiles repository. It is designed to be read by both humans and AI assistants to understand the testing architecture, workflows, and implementation details.

## Overview

The testing system validates dotfiles configuration in isolated Docker containers. It supports three main test execution modes:

1. **Change Detection Test** (`make test`): Runs only tests affected by changed files (default, frequently used)
2. **All Tests** (`make test-all`): Runs all tests regardless of changes
3. **Baseline Update** (`make test-all BASELINE=1`): Runs all tests and saves results as baseline for comparison

The system uses Docker volumes for persistent state (chezmoi state, cargo data, rustup data, environment snapshots) to enable efficient incremental testing.

## Test Types

### 1. Change Detection Test (`make test`)

**Purpose**: Run tests only for changed files to minimize execution time during development.

**How it works**:
1. **Change Detection**: Uses `scripts/detect-changes.sh` to detect uncommitted changes via `git diff` (HEAD vs working directory, including staged changes)
2. **Pattern Matching**: Maps changed files to relevant tests using `.test-mapping.json` (glob pattern matching)
3. **Dependency Resolution**: If any changed file has `affects_all: true` flag (e.g., `bashrc` changes), runs all tests
4. **Test Execution**: Runs only the affected tests in Docker container
5. **Fallback**: If no changes detected, runs all tests (safe default)

**Exit code policy**:
- **FAIL**: fatal (Make targets exit non-zero)
- **WARN**: non-fatal (Make targets still exit 0 unless there is a FAIL)

**Debug knobs**:
- `DEBUG_DETECT_CHANGES=1`: Print why change detection falls back to running all tests

**Example**:
```bash
# Modify zellij configuration
vim home/dot_config/zellij/config.kdl.tmpl

# Run change detection test
make test
# Only runs: tests/zellij-test.sh
```

**Implementation details**:
- Change detection script: `scripts/detect-changes.sh`
- Mapping file: `.test-mapping.json` (JSON format with pattern-to-tests mapping)
- Pattern matching: Converts glob patterns (`**`, `*`) to regex for matching
- Special handling: Files with `affects_all: true` trigger all tests (e.g., `home/dot_bashrc.d/**` affects all tools due to PATH impact)

### 2. All Tests (`make test-all`)

**Purpose**: Run all tests regardless of changes. Used for initial setup, after major changes, or before releases.

**How it works**:
1. **Apply Configuration**: Runs `scripts/apply-container.sh` (applies chezmoi configuration, executes run_onchange scripts)
2. **Test Execution**: Runs all test files (all `*-test.sh` files in `tests/` directory)
3. **Snapshot Creation**: Creates environment snapshot on success (no FAIL) via `scripts/create-snapshot.sh`
4. **Result Recording**: Records test results in JSON format via `scripts/record-test-results.sh`

**Execution time**:
- 2-3 minutes (if already installed, using cached Docker volumes)
- 10-20 minutes (first time, installing all tools)

**Use cases**:
- Initial setup verification
- After major changes (e.g., bashrc refactoring)
- Before releases or pull requests
- Creating baseline for comparison

**Snapshot system**:
- Snapshot location: `~/.local/share/env-snapshot/` (Docker volume: `env-snapshot`)
- Snapshot contents:
  - `local-bin-files.txt`: List of executables in `~/.local/bin`
  - `cargo-bin-files.txt`: List of executables in `~/.cargo/bin`
  - `config-structure.txt`: Directory structure in `~/.config` (excluding chezmoi)
  - `apt-packages.txt`: List of installed apt packages
  - `timestamp.txt`: Snapshot creation timestamp
- Used by `make reset` to detect and remove manually installed tools

### 3. Baseline Update (`make test-all BASELINE=1`)

**Purpose**: Save test results as baseline for comparison. Useful for detecting regressions.

**How it works**:
1. Runs all tests (same as `make test-all`)
2. Saves results to both `latest.json` and `baseline.json` via `scripts/record-test-results.sh --baseline`

**Usage**:
```bash
make test-all BASELINE=1
```

**Baseline comparison**:
- Compare current results with baseline: `bash scripts/compare-test-results.sh`
- Detects regressions (tests that passed in baseline but failed in latest)
- Detects improvements (tests that failed in baseline but passed in latest)
- Detects new tests (tests in latest but not in baseline)
- Detects missing tests (tests in baseline but not in latest)

## Change Detection Mechanism

The change detection system (`scripts/detect-changes.sh`) maps changed files to relevant tests using pattern matching.

### Process Flow

1. **Git Diff**: Detects uncommitted changes (HEAD vs working directory, including staged changes)
   - Uses `git diff --name-only HEAD` for unstaged changes
   - Uses `git diff --cached --name-only` for staged changes
   - Merges and deduplicates both lists

2. **Pattern Matching**: Matches changed files against patterns in `.test-mapping.json`
   - Glob pattern conversion: `**` → `.*`, `*` → `[^/]*`, `.` → `\.`
   - Pattern matching uses regex against file paths

3. **Dependency Resolution**: 
   - If any changed file has `affects_all: true` flag, runs all tests
   - Common cases: `home/dot_bashrc*`, `home/dot_bash_profile.tmpl`, `home/dot_bashrc.d/**` (PATH impact)

4. **Test Selection**: Collects unique test files from matching patterns

5. **Fallback**: If no changes detected or no specific tests matched, runs all tests (safe default)

### Mapping File Format

`.test-mapping.json` structure:
```json
{
  "version": "1.0",
  "description": "Mapping between source files and test files",
  "mappings": [
    {
      "pattern": "home/dot_config/zellij/**",
      "tests": ["tests/zellij-test.sh"],
      "description": "zellij configuration"
    },
    {
      "pattern": "home/dot_bashrc.d/**",
      "tests": ["tests/bash-config-test.sh"],
      "affects_all": true,
      "description": "bashrc.d changes affect all tools (PATH impact)"
    }
  ]
}
```

**Pattern matching rules**:
- `**`: Matches any path including `/` (recursive)
- `*`: Matches any characters except `/` (single level)
- Patterns are matched against full file paths relative to repository root

**Special flags**:
- `affects_all: true`: If any file matching this pattern changes, all tests are run

### Edge Cases

- **Not a git repository**: Falls back to running all tests (silent, unless `DEBUG_DETECT_CHANGES=1`)
- **jq not available**: Falls back to running all tests (silent, unless `DEBUG_DETECT_CHANGES=1`)
- **Deleted files**: Skipped (pattern matching only checks existing files)
- **No changes detected**: Runs all tests (safe default)

## Test Results

Test results are automatically recorded in JSON format for analysis and comparison.

### Result Storage

- **Location**: `.test-results/` (Git-ignored)
- **Files**:
  - `latest.json`: Most recent test results
  - `baseline.json`: Baseline results (created with `BASELINE=1`)
  - `history/`: Timestamped history files (`test-results-YYYYMMDD-HHMMSS.json`)

### Result Format

```json
{
  "timestamp": "2024-01-01T12:00:00+00:00",
  "git_commit": "abc123...",
  "test_type": "changed|all",
  "tests": {
    "zellij-test.sh": {
      "status": "pass|fail",
      "duration_seconds": 5,
      "warn_count": 0,
      "log_file": "/path/to/log"
    }
  },
  "config_hashes": {
    "/root/.bashrc": "sha256:...",
    "/root/.config/starship.toml": "sha256:..."
  },
  "summary": {
    "total": 10,
    "passed": 9,
    "failed": 1,
    "warned": 2
  }
}
```

**Fields**:
- `timestamp`: ISO 8601 timestamp of test execution
- `git_commit`: Git commit hash (if in git repo)
- `test_type`: `"changed"` (change detection) or `"all"` (all tests)
- `tests`: Object mapping test names to results
- `config_hashes`: SHA256 hashes of key configuration files (for change detection)
- `summary`: Aggregate statistics

### Result Recording

**Script**: `scripts/record-test-results.sh

**Input**: `TEST_RESULTS_JSONL` environment variable (JSON Lines format, one JSON object per test)

**Process**:
1. Reads JSONL file (one test result per line)
2. Validates JSON (strict mode: `STRICT_RESULTS=1` fails on invalid JSON, default: best-effort)
3. Aggregates into single JSON object
4. Computes config file hashes (low-cost, key files only)
5. Saves to `latest.json` and history file
6. Optionally saves to `baseline.json` if `--baseline` flag is set

**Strict mode**:
- `STRICT_RESULTS=1`: Fail if any JSONL line is invalid JSON or missing required keys
- Default: Skip invalid JSONL lines (best-effort mode)

### Result Comparison

**Script**: `scripts/compare-test-results.sh`

**Usage**:
```bash
bash scripts/compare-test-results.sh
```

**Output**:
- Regressions: Tests that passed in baseline but failed in latest
- Improvements: Tests that failed in baseline but passed in latest
- New tests: Tests in latest but not in baseline
- Missing tests: Tests in baseline but not in latest

**Exit codes**:
- Exit 1: Regressions detected
- Exit 1: Missing tests detected (if `STRICT_COMPARE=1`)
- Exit 0: No regressions

**Strict mode**:
- `STRICT_COMPARE=1`: Treat missing tests in latest results as an error (exit 1)
- Default: Missing tests are warnings only (exit 0)

## Running Single Tests

### From Host Machine

```bash
# Run specific test
bash tests/zellij-test.sh
```

**Note**: Tests are designed to run in Docker containers with proper environment setup. Running directly on host may fail due to missing dependencies or environment differences.

### From Docker Container

```bash
# Enter container
make dev

# Run specific test
bash tests/zellij-test.sh
```

### Manual Docker Run

```bash
docker run --rm -it \
  -v "$(pwd):/workspace" -w /workspace \
  -v dotfiles-state:/root/.config/chezmoi \
  -v cargo-data:/root/.cargo \
  -v rustup-data:/root/.rustup \
  -v env-snapshot:/root/.local/share/env-snapshot \
  -v "$HOME/.config/gh:/root/.config/gh:ro" \
  -e GITHUB_TOKEN="$(gh auth token 2>/dev/null || echo '')" \
  dotfiles-test:ubuntu24.04 \
  bash -lc 'bash scripts/apply-container.sh && bash tests/zellij-test.sh'
```

## Test Structure

### Test File Naming

- **Pattern**: `tests/*-test.sh`
- **Examples**: `tests/zellij-test.sh`, `tests/bash-config-test.sh`, `tests/cargo-test.sh`

### Test File Structure

```bash
#!/usr/bin/env bash
# Test description
# Usage: bash tests/tool-test.sh

set -euo pipefail

# Import test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing tool-name"
echo "=========================================="

# Test 1: Installation check
assert_executable "tool" "tool installed"

# Test 2: Version check
assert_command "tool --version" "tool version prints"

# Test 3: Configuration file check
assert_file_exists "$HOME/.config/tool/config" "tool config file exists"

# Test 4: Functionality test
assert_command "tool --help" "tool help works"

# Print summary
print_summary
```

### Test Helpers

**Location**: `tests/lib/helpers.sh`

**Common functions**:

- `pass "message"`: Record test success (increments `TEST_PASS` counter)
- `fail "message"`: End script immediately with error (fail-fast, exit 1)
- `warn "message"`: Non-fatal warning (increments `TEST_WARN` counter, does not exit)
- `assert_command "cmd" ["desc"] ["quiet"]`: Assert command succeeds (exit code 0)
  - `quiet`: If `"true"`, suppress output in error message (default: `false`)
- `assert_file_exists "path" ["desc"]`: Assert file exists
- `assert_executable "cmd" ["desc"]`: Assert command exists in PATH (`command -v`)
- `assert_string_contains "actual" "expected" ["desc"]`: Assert string contains substring
- `assert_command_fails "cmd" ["desc"] ["expected_exit"]`: Assert command fails (non-zero exit code)
  - `expected_exit`: Optional, specific exit code to expect (default: any non-zero)
- `assert_exit_code "cmd" "expected_exit" ["desc"]`: Assert command returns specific exit code
- `assert_output_contains "cmd" "expected" ["desc"]`: Assert command output contains string
- `print_summary`: Print test summary (pass count, warn count, total)

**Global variables**:
- `TEST_PASS`: Pass counter (incremented by `pass`)
- `TEST_WARN`: Warning counter (incremented by `warn`)

**Color codes** (disabled when not a TTY):
- `RED`, `GREEN`, `YELLOW`, `NC` (No Color)

**Error handling**:
- Tests use `set -euo pipefail` for strict error checking
- `fail()` immediately exits with code 1 (fail-fast)
- `warn()` does not exit (non-fatal)

### Test Standards

For personal chezmoi dotfiles management, we use a 3-level testing standard:

#### Level 1: Basic Verification (Minimum)

**Required for all tools:**
- Installation check: `assert_executable "tool"`
- Version check: `assert_command "tool --version"`
- Config file existence check (if managed by chezmoi): `assert_file_exists "$HOME/.config/tool/config"`

#### Level 2: Functionality Verification (Recommended)

**Level 1 + add:**
- Basic functionality test (one main feature)
- Config file validation (if managed by chezmoi, e.g., `zellij setup --check`)

#### Level 3: Detailed Verification (Only when needed)

**Level 2 + add:**
- Integration test (e.g., git integration for delta)
- Error handling test (verify it doesn't crash on invalid input)

**Guidelines**:
- Level 1 is mandatory for all tools
- Level 2 is recommended for tools with configuration files
- Level 3 is only for tools that require complex integration testing
- Test execution time should be reasonable (Level 1: <1 second, Level 2: 1-2 seconds, Level 3: <10 seconds per test)

## Makefile Targets

### `make test`

**Purpose**: Change detection test (default, frequently used)

**Process**:
1. Builds Docker image if needed
2. Runs `scripts/apply-container.sh` in container
3. Detects changed files via `scripts/detect-changes.sh`
4. Runs affected tests (or all tests if no changes detected)
5. Records results via `scripts/record-test-results.sh`
6. Exits with code 1 if any test fails (FAIL), code 0 if all pass (WARN is non-fatal)

**Performance measurement**:
- Logs execution time for `apply-container.sh` and each test
- Logs stored in `~/.cache/test-logs/` (container path)
- Results stored in JSONL format (`TEST_RESULTS_JSONL` environment variable)

### `make test-all`

**Purpose**: Run all tests regardless of changes

**Process**:
1. Builds Docker image if needed
2. Runs `scripts/apply-container.sh` in container
3. Runs all test files (`tests/*-test.sh`)
4. Creates environment snapshot on success (no FAIL) via `scripts/create-snapshot.sh`
5. Records results via `scripts/record-test-results.sh`
6. Optionally saves baseline if `BASELINE=1` is set

**Snapshot creation**:
- Only created if all tests pass (no FAIL)
- Snapshot location: `~/.local/share/env-snapshot/` (Docker volume: `env-snapshot`)
- Used by `make reset` to detect manually installed tools

### `make test-all BASELINE=1`

**Purpose**: Run all tests and save baseline

**Process**:
- Same as `make test-all`, but also saves results to `baseline.json`

### `make dev`

**Purpose**: Interactive development shell

**Process**:
1. Builds Docker image if needed
2. Runs `scripts/apply-container.sh` in container
3. Drops into interactive login shell (`bash -l`)

**Use cases**:
- Manual testing and debugging
- Verifying configuration changes
- Testing tool installations

**Exit code**: 130 (SIGINT) is treated as success (Ctrl+C to exit)

### `make clean`

**Purpose**: Remove persistent Docker volumes

**Usage**:
- `make clean`: Remove volumes (next `make dev` or `make test` will rebuild)
- `make clean REBUILD=1`: Remove volumes and rebuild environment (complete reset)

**Volumes removed**:
- `dotfiles-state`: chezmoi state
- `cargo-data`: Rust cargo cache
- `rustup-data`: Rust toolchain data
- `env-snapshot`: Environment snapshots
- `vim-data`: Vim plugins

### `make reset`

**Purpose**: Reset manual installations while preserving chezmoi state

**Process**:
1. Compares current state with snapshot (via `scripts/reset-manual-installs.sh`)
2. Removes manually installed tools (files in `~/.local/bin` or `~/.cargo/bin` not in snapshot)
3. Preserves chezmoi-managed state

**Use cases**:
- Remove manually installed tools after testing
- Return to clean state A (after state B = A + manually installed tools)

## Docker Environment

### Volumes

Persistent Docker volumes for state management:

- **`dotfiles-state`**: chezmoi state (`~/.config/chezmoi`)
- **`cargo-data`**: Rust cargo cache (`~/.cargo`)
- **`rustup-data`**: Rust toolchain data (`~/.rustup`)
- **`env-snapshot`**: Environment snapshots (`~/.local/share/env-snapshot`)
- **`vim-data`**: Vim plugins (`~/.vim`)

**Benefits**:
- Faster test execution (cached installations)
- Incremental testing (only installs new tools)
- State preservation across container runs

### Image

**Base image**: `dotfiles-test:ubuntu24.04` (built from `Dockerfile`)

**Contents**:
- Ubuntu 24.04
- Essential tools: `git`, `curl`, `bash-completion`
- Locales: `en_US.UTF-8`
- Pre-installed chezmoi (via installation script in Dockerfile)

### GitHub Authentication

**Purpose**: Higher API rate limits for GitHub API requests (5000/hour vs 60/hour unauthenticated)

**Implementation**:
- Mounts `~/.config/gh` from host (read-only) if available
- Passes `GITHUB_TOKEN` environment variable from host (`gh auth token`)
- Used by tools like `gh` CLI and `ghq` during installation

## Troubleshooting

### Change Detection Not Working

**Symptoms**: `make test` always runs all tests

**Solutions**:
```bash
# Check if in git repo
git rev-parse --git-dir

# Check if jq is installed
command -v jq

# Check mapping file
cat .test-mapping.json

# Enable debug output
DEBUG_DETECT_CHANGES=1 make test
```

**Common causes**:
- Not in git repository (Docker with git worktrees)
- `jq` not installed
- No changes detected (runs all tests as safe default)

### Tests Not Running

**Symptoms**: Tests fail to execute or hang

**Solutions**:
```bash
# Check what files changed
git diff --name-only HEAD

# Check if test file exists
ls -la tests/zellij-test.sh

# Manually run test
bash tests/zellij-test.sh

# Check Docker container
make dev
```

**Common causes**:
- Test file missing or not executable
- Docker container issues
- Missing dependencies in test environment

### Baseline Not Found

**Symptoms**: `bash scripts/compare-test-results.sh` fails with "Baseline file not found"

**Solutions**:
```bash
# Create baseline
make test-all BASELINE=1

# Verify baseline exists
ls -la .test-results/baseline.json
```

### Docker Container Hangs

**Symptoms**: `make dev` or `make test` hangs

**Solutions**:
```bash
# Stop all running containers
docker ps -q | xargs -r docker stop

# Check GitHub API rate limit
curl -s https://api.github.com/rate_limit | jq '.rate'

# Clean and rebuild
make clean REBUILD=1
```

**Common causes**:
- GitHub API rate limit exceeded (check with `gh auth status`)
- Docker volume lock issues
- Network connectivity issues

### Test Failures

**Symptoms**: Tests fail with unclear error messages

**Solutions**:
```bash
# Check test log file (from test output)
cat /path/to/test-log-file

# Run test manually with verbose output
bash -x tests/zellij-test.sh

# Check environment in container
make dev
# Then: command -v tool, echo $PATH, etc.
```

### Snapshot Issues

**Symptoms**: `make reset` doesn't work correctly

**Solutions**:
```bash
# Check if snapshot exists
docker run --rm -v env-snapshot:/snapshot -it ubuntu:24.04 ls -la /snapshot

# Recreate snapshot
make test-all  # Creates snapshot on success

# Verify snapshot contents
docker run --rm -v env-snapshot:/snapshot -it ubuntu:24.04 cat /snapshot/timestamp.txt
```

## Best Practices

### Writing Tests

1. **Use test helpers**: Always use functions from `tests/lib/helpers.sh` instead of raw assertions
2. **Fail-fast**: Use `fail()` for critical errors (immediate exit)
3. **Non-fatal warnings**: Use `warn()` for non-critical issues (does not exit)
4. **Descriptive messages**: Provide clear descriptions in assertions
5. **PATH handling**: Ensure PATH includes required directories (e.g., `~/.local/bin`, `~/.cargo/bin`)
6. **Timeout handling**: Use `timeout` command for commands that may hang (e.g., `zellij setup --check`)

### Test Execution

1. **Change detection first**: Use `make test` during development (faster)
2. **Full test suite**: Use `make test-all` before commits or releases
3. **Baseline updates**: Update baseline after major changes (`make test-all BASELINE=1`)
4. **Interactive debugging**: Use `make dev` for manual testing

### Maintenance

1. **Update mappings**: Add new test mappings to `.test-mapping.json` when adding new tools
2. **Test standards**: Follow 3-level testing standard (Level 1 minimum, Level 2 recommended, Level 3 when needed)
3. **Result analysis**: Regularly compare results with baseline to detect regressions
4. **Snapshot management**: Recreate snapshots after major environment changes
