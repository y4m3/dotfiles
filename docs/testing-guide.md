# Testing Guide

This guide explains the testing system, change detection mechanism, and how to use test results.

## Test Types

### 1. Change Detection Test (`make test`)

**Purpose**: Run tests only for changed files (default, frequently used)

**How it works**:
1. Detects changed files using `git diff`
2. Maps changed files to relevant tests using `.test-mapping.json`
3. Runs only the affected tests
4. If no changes detected, runs all tests (safe default)

**Execution time**: Seconds to minutes (depends on change scope)

**Use cases**:
- After modifying a specific tool's configuration
- After updating a single `run_once` script
- Daily development workflow

**Example**:
```bash
# Modify zellij configuration
vim home/dot_config/zellij/config.kdl.tmpl

# Run change detection test
make test
# Only runs: tests/zellij-test.sh
```

### 2. All Tests (`make test-all`)

**Purpose**: Run all tests regardless of changes

**How it works**:
1. Runs `apply-container.sh` (checks/executes `run_once` scripts)
2. Runs all test files (all `*-test.sh` files in `tests/` directory)
3. Creates environment snapshot on success

**Execution time**: 2-3 minutes (if already installed), 10-20 minutes (first time)

**Use cases**:
- Initial setup
- After major changes
- Periodic full verification (weekly, etc.)
- Before releases

**Example**:
```bash
# Run all tests
make test-all
# Runs all tests and creates snapshot on success
```

### 3. Baseline Update (`make test-all BASELINE=1`)

**Purpose**: Save test results as baseline for comparison

**How it works**:
1. Runs all tests (same as `make test-all`)
2. Saves results to `.test-results/baseline.json`

**Use cases**:
- After initial setup
- After major changes
- To establish a known-good state

**Example**:
```bash
# Run all tests and save as baseline
make test-all BASELINE=1
```

## Change Detection Mechanism

### How It Works

1. **Git Diff**: Compares current HEAD with specified base commit (default: HEAD)
2. **Pattern Matching**: Matches changed files against patterns in `.test-mapping.json`
3. **Dependency Resolution**: If a file affects all tests (e.g., `bashrc` changes), runs all tests
4. **Test Execution**: Runs only the affected tests

### Mapping File

The `.test-mapping.json` file defines:
- File patterns (e.g., `home/run_once_*zellij*.sh.tmpl`)
- Associated tests (e.g., `tests/zellij-test.sh`)
- Dependencies (e.g., `bashrc` changes affect all tests)

### Example Mappings

```json
{
  "pattern": "home/run_once_265-terminal-zellij.sh.tmpl",
  "tests": ["tests/zellij-test.sh"]
},
{
  "pattern": "home/dot_bashrc*",
  "tests": ["tests/bash-config-test.sh"],
  "affects_all": true
}
```

### Special Cases

- **`affects_all: true`**: If any file with this flag changes, all tests are run
  - Examples: `dot_bashrc*`, `dot_bash_profile.tmpl`, `dot_bashrc.d/**`
  - Reason: PATH changes affect all tools

- **No changes detected**: Runs all tests (safe default)

- **Pattern matching**: Uses glob patterns (`*`, `**`) converted to regex

## Test Results

### Recording

Test results are automatically recorded in JSON format:
- Location: `.test-results/` (Git-ignored)
- Files:
  - `latest.json`: Most recent test results
  - `baseline.json`: Baseline results for comparison
  - `history/`: Timestamped history

### Result Format

```json
{
  "timestamp": "2025-12-29T02:37:04+09:00",
  "git_commit": "abc123...",
  "test_type": "changed|all",
  "tests": {
    "zellij-test.sh": {
      "status": "pass",
      "duration": 2.5,
      "tool_version": "0.43.1"
    }
  },
  "config_hashes": {
    "~/.bashrc": "sha256:...",
    "~/.config/starship.toml": "sha256:..."
  }
}
```

### Comparison

Use `scripts/compare-test-results.sh` to compare current results with baseline:

```bash
bash scripts/compare-test-results.sh
```

This will show:
- Regressions (tests that passed in baseline but failed in latest)
- Improvements (tests that failed in baseline but passed in latest)
- New tests
- Missing tests

## Verification Procedures

This section provides step-by-step procedures to verify that all tools are correctly installed and configured.

### Prerequisites

- Docker is installed and running
- Host system has `gh` CLI installed and authenticated (optional, but recommended for higher GitHub API rate limits)
- This repository is cloned and you are in the repository root directory

### Step 1: Clean Environment Setup

Start with a clean environment to ensure fresh installation:

```bash
# Remove all persistent volumes
make clean

# Rebuild Docker image (if needed)
make build
```

### Step 2: Run Full Test Suite

Execute the complete test suite which will:
- Install all tools via `run_once` scripts
- Run all test cases
- Create environment snapshot on success

```bash
make test-all
```

**Expected Result:**
- All tests should pass
- Environment snapshot should be created successfully
- No errors related to GitHub API rate limits

### Step 3: Verify GitHub API Authentication

Check if GitHub API authentication is working correctly:

```bash
docker run --rm \
  -v "$(pwd):/workspace" -w /workspace \
  -v dotfiles-state:/root/.config/chezmoi \
  -v cargo-data:/root/.cargo \
  -v rustup-data:/root/.rustup \
  -v env-snapshot:/root/.local/share/env-snapshot \
  -v "$HOME/.config/gh:/root/.config/gh:ro" \
  -e GITHUB_TOKEN="$(gh auth token 2>/dev/null || echo '')" \
  dotfiles-test:ubuntu24.04 \
  bash -lc 'if [ -n "${GITHUB_TOKEN:-}" ]; then \
    echo "✓ Using authenticated requests (5000/hour limit)"; \
    curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/rate_limit | \
    jq "{remaining: .rate.remaining, limit: .rate.limit}"; \
  else \
    echo "⚠ Using unauthenticated requests (60/hour limit)"; \
    curl -s https://api.github.com/rate_limit | \
    jq "{remaining: .rate.remaining, limit: .rate.limit}"; \
  fi'
```

**Expected Result:**
- If `gh` is authenticated on host: `limit: 5000, remaining: 4995+`
- If `gh` is not authenticated: `limit: 60, remaining: 50+`

### Step 4: Verify Tool Installation

Check that all expected tools are installed:

```bash
docker run --rm \
  -v "$(pwd):/workspace" -w /workspace \
  -v dotfiles-state:/root/.config/chezmoi \
  -v cargo-data:/root/.cargo \
  -v rustup-data:/root/.rustup \
  -v env-snapshot:/root/.local/share/env-snapshot \
  -v "$HOME/.config/gh:/root/.config/gh:ro" \
  -e GITHUB_TOKEN="$(gh auth token 2>/dev/null || echo '')" \
  dotfiles-test:ubuntu24.04 \
  bash -lc 'bash scripts/apply-container.sh > /dev/null 2>&1 && \
    echo "=== Installed Tools ===" && \
    ls -1 ~/.local/bin/ | sort && \
    echo "" && \
    echo "=== Tool Count ===" && \
    echo "Total: $(ls -1 ~/.local/bin/ | wc -l) tools"'
```

### Step 5: Verify Tool Versions

Verify that each tool can be executed and shows version information:

```bash
docker run --rm \
  -v "$(pwd):/workspace" -w /workspace \
  -v dotfiles-state:/root/.config/chezmoi \
  -v cargo-data:/root/.cargo \
  -v rustup-data:/root/.rustup \
  -v env-snapshot:/root/.local/share/env-snapshot \
  -v "$HOME/.config/gh:/root/.config/gh:ro" \
  -e GITHUB_TOKEN="$(gh auth token 2>/dev/null || echo '')" \
  dotfiles-test:ubuntu24.04 \
  bash -lc 'bash scripts/apply-container.sh > /dev/null 2>&1 && \
    echo "=== Tool Versions ===" && \
    for tool in ~/.local/bin/*; do \
      if [ -f "$tool" ] && [ -x "$tool" ]; then \
        tool_name=$(basename "$tool"); \
        version=$("$tool" --version 2>&1 | head -1 || echo "N/A"); \
        echo "✓ $tool_name: $version"; \
      fi; \
    done'
```

**Expected Result:**
- All tools should show version information
- No "N/A" messages

### Step 6: Verify PATH Configuration

Check that PATH is correctly configured to include tool directories:

```bash
docker run --rm \
  -v "$(pwd):/workspace" -w /workspace \
  -v dotfiles-state:/root/.config/chezmoi \
  -v cargo-data:/root/.cargo \
  -v rustup-data:/root/.rustup \
  -v env-snapshot:/root/.local/share/env-snapshot \
  -v "$HOME/.config/gh:/root/.config/gh:ro" \
  -e GITHUB_TOKEN="$(gh auth token 2>/dev/null || echo '')" \
  dotfiles-test:ubuntu24.04 \
  bash -lc 'bash scripts/apply-container.sh > /dev/null 2>&1 && \
    source ~/.bash_profile && \
    echo "=== PATH Configuration ===" && \
    echo "$PATH" | tr ":" "\n" | grep -E "(local/bin|cargo/bin)" && \
    echo "" && \
    echo "=== Tool Availability in PATH ===" && \
    for tool in ~/.local/bin/*; do \
      if [ -f "$tool" ] && [ -x "$tool" ]; then \
        tool_name=$(basename "$tool"); \
        if command -v "$tool_name" >/dev/null 2>&1; then \
          echo "✓ $tool_name: available in PATH"; \
        else \
          echo "✗ $tool_name: NOT in PATH"; \
        fi; \
      fi; \
    done'
```

**Expected Result:**
- `~/.local/bin` and `~/.cargo/bin` should be in PATH
- All tools should be available via `command -v`

### Step 7: Verify Configuration Files

Check that configuration files are correctly deployed:

```bash
docker run --rm \
  -v "$(pwd):/workspace" -w /workspace \
  -v dotfiles-state:/root/.config/chezmoi \
  -v cargo-data:/root/.cargo \
  -v rustup-data:/root/.rustup \
  -v env-snapshot:/root/.local/share/env-snapshot \
  -v "$HOME/.config/gh:/root/.config/gh:ro" \
  -e GITHUB_TOKEN="$(gh auth token 2>/dev/null || echo '')" \
  dotfiles-test:ubuntu24.04 \
  bash -lc 'bash scripts/apply-container.sh > /dev/null 2>&1 && \
    echo "=== Configuration Files ===" && \
    echo "Bash config:" && \
    test -f ~/.bashrc && echo "  ✓ ~/.bashrc exists" || echo "  ✗ ~/.bashrc missing" && \
    test -f ~/.bash_profile && echo "  ✓ ~/.bash_profile exists" || echo "  ✗ ~/.bash_profile missing" && \
    test -d ~/.bashrc.d && echo "  ✓ ~/.bashrc.d exists" || echo "  ✗ ~/.bashrc.d missing" && \
    echo "" && \
    echo "Tool configs:" && \
    test -f ~/.config/starship.toml && echo "  ✓ starship.toml exists" || echo "  ✗ starship.toml missing" && \
    test -f ~/.config/zellij/config.kdl && echo "  ✓ zellij/config.kdl exists" || echo "  ✗ zellij/config.kdl missing"'
```

### Step 8: Verify Snapshot Creation

Check that environment snapshot was created correctly:

```bash
docker run --rm \
  -v "$(pwd):/workspace" -w /workspace \
  -v dotfiles-state:/root/.config/chezmoi \
  -v cargo-data:/root/.cargo \
  -v rustup-data:/root/.rustup \
  -v env-snapshot:/root/.local/share/env-snapshot \
  -v "$HOME/.config/gh:/root/.config/gh:ro" \
  -e GITHUB_TOKEN="$(gh auth token 2>/dev/null || echo '')" \
  dotfiles-test:ubuntu24.04 \
  bash -lc 'bash scripts/apply-container.sh > /dev/null 2>&1 && \
    bash scripts/create-snapshot.sh && \
    echo "=== Snapshot Files ===" && \
    ls -lh ~/.local/share/env-snapshot/ && \
    echo "" && \
    echo "=== Snapshot Contents ===" && \
    echo "Local bin files: $(wc -l < ~/.local/share/env-snapshot/local-bin-files.txt)" && \
    echo "Cargo bin files: $(wc -l < ~/.local/share/env-snapshot/cargo-bin-files.txt)" && \
    echo "Config items: $(wc -l < ~/.local/share/env-snapshot/config-structure.txt)" && \
    echo "Apt packages: $(wc -l < ~/.local/share/env-snapshot/apt-packages.txt)"'
```

### Step 9: Verify Reset Functionality

Test the reset functionality to ensure it works correctly:

```bash
# First, manually install a test tool
docker run --rm -it \
  -v "$(pwd):/workspace" -w /workspace \
  -v dotfiles-state:/root/.config/chezmoi \
  -v cargo-data:/root/.cargo \
  -v rustup-data:/root/.rustup \
  -v env-snapshot:/root/.local/share/env-snapshot \
  -v "$HOME/.config/gh:/root/.config/gh:ro" \
  -e GITHUB_TOKEN="$(gh auth token 2>/dev/null || echo '')" \
  dotfiles-test:ubuntu24.04 \
  bash -lc 'bash scripts/apply-container.sh > /dev/null 2>&1 && \
    echo "test-tool" > ~/.local/bin/test-tool && \
    chmod +x ~/.local/bin/test-tool && \
    echo "Created test-tool" && \
    ls -1 ~/.local/bin/ | grep test-tool'

# Then reset and verify it's removed
make reset

# Verify test-tool is removed
docker run --rm \
  -v "$(pwd):/workspace" -w /workspace \
  -v dotfiles-state:/root/.config/chezmoi \
  -v cargo-data:/root/.cargo \
  -v rustup-data:/root/.rustup \
  -v env-snapshot:/root/.local/share/env-snapshot \
  -v "$HOME/.config/gh:/root/.config/gh:ro" \
  -e GITHUB_TOKEN="$(gh auth token 2>/dev/null || echo '')" \
  dotfiles-test:ubuntu24.04 \
  bash -lc 'bash scripts/reset-manual-installs.sh && \
    if [ -f ~/.local/bin/test-tool ]; then \
      echo "✗ test-tool still exists (reset failed)"; \
    else \
      echo "✓ test-tool removed (reset successful)"; \
    fi'
```

### Step 10: Interactive Verification

Enter the container interactively to manually verify tools:

```bash
make dev
```

Inside the container, verify:

```bash
# Check PATH
echo $PATH | grep -E "(local/bin|cargo/bin)"

# Test tools interactively
# Run --version for installed tools to verify they work

# Check configuration files
cat ~/.bashrc | head -20
cat ~/.config/starship.toml | head -20
cat ~/.config/zellij/config.kdl | head -20
```

### Quick Verification Checklist

Use this checklist for quick verification:

- [ ] `make test-all` passes without errors
- [ ] GitHub API authentication working (5000/hour limit if authenticated)
- [ ] All tools installed in `~/.local/bin`
- [ ] All tools show version information
- [ ] PATH includes `~/.local/bin` and `~/.cargo/bin`
- [ ] All tools available via `command -v`
- [ ] Configuration files exist (`~/.bashrc`, `~/.bash_profile`, `~/.config/starship.toml`, `~/.config/zellij/config.kdl`)
- [ ] Environment snapshot created successfully
- [ ] Reset functionality works correctly
- [ ] Interactive shell works (`make dev`)

## Troubleshooting

### Tools Not Found After Installation

**Symptoms:**
- `command not found` errors
- Tools exist in `~/.local/bin` but not in PATH

**Solution:**
```bash
# Verify PATH is set correctly
source ~/.bash_profile
echo $PATH

# Manually add to PATH if needed
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
```

### GitHub API Rate Limit Errors

**Symptoms:**
- `403` or `429` errors during installation
- "rate limit" error messages

**Solution:**
1. Check if `gh` is authenticated on host:
   ```bash
   gh auth status
   ```

2. Verify GITHUB_TOKEN is passed to container:
   ```bash
   docker run --rm ... -e GITHUB_TOKEN="$(gh auth token)" ... \
     bash -lc 'echo "Token: ${GITHUB_TOKEN:0:10}..."'
   ```

3. Wait for rate limit to reset:
   ```bash
   curl -s https://api.github.com/rate_limit | jq '.rate.reset'
   ```

### Chezmoi State Conflicts

**Symptoms:**
- Scripts marked as executed but tools not installed
- Lock contention errors

**Solution:**
```bash
# Clean chezmoi state
make clean

# Rebuild from scratch
make test-all
```

### Snapshot Not Created

**Symptoms:**
- `make test-all` passes but snapshot directory is empty

**Solution:**
```bash
# Manually create snapshot
docker run --rm \
  -v "$(pwd):/workspace" -w /workspace \
  -v env-snapshot:/root/.local/share/env-snapshot \
  dotfiles-test:ubuntu24.04 \
  bash -lc 'bash scripts/create-snapshot.sh'
```

### Change Detection Not Working

**Problem**: `make test` runs all tests even when files changed

**Possible causes**:
1. Not in a git repository
2. `jq` not installed (required for JSON parsing)
3. `.test-mapping.json` not found
4. Pattern matching issue

**Solution**:
```bash
# Check if in git repo
git rev-parse --git-dir

# Check if jq is installed
command -v jq

# Check mapping file
cat .test-mapping.json
```

### Tests Not Running

**Problem**: Specific test not running when file changes

**Possible causes**:
1. Pattern not matching in `.test-mapping.json`
2. Test file doesn't exist
3. Git diff not detecting changes

**Solution**:
```bash
# Check what files changed
git diff --name-only HEAD

# Check mapping
jq '.mappings[] | select(.pattern | contains("zellij"))' .test-mapping.json

# Manually run test
bash tests/zellij-test.sh
```

### Baseline Not Found

**Problem**: `compare-test-results.sh` fails with "Baseline file not found"

**Solution**:
```bash
# Create baseline
make test-all BASELINE=1
```

### Test Results Not Recorded

**Problem**: Test results not saved to `.test-results/`

**Possible causes**:
1. Directory not writable
2. Script not executed
3. JSON parsing error

**Solution**:
```bash
# Check directory permissions
ls -la .test-results/

# Manually record results
bash scripts/record-test-results.sh
```

## Best Practices

1. **Use `make test` for daily development**: Fast feedback on changes
2. **Use `make test-all` before commits**: Ensure all tests pass
3. **Update baseline after major changes**: `make test-all BASELINE=1`
4. **Compare results regularly**: Check for regressions
5. **Follow verification procedures**: Use the verification steps above to ensure everything is working correctly

## Workflow Examples

### Daily Development

```bash
# 1. Make changes
vim home/dot_config/zellij/config.kdl.tmpl

# 2. Run change detection test
make test
# Only runs zellij-test.sh

# 3. If all pass, commit
git add home/dot_config/zellij/config.kdl.tmpl
git commit -m "Update zellij config"
```

### Major Changes

```bash
# 1. Make major changes
vim home/dot_bashrc.tmpl
vim home/run_once_265-terminal-zellij.sh.tmpl

# 2. Run all tests
make test-all
# Runs all tests, creates snapshot

# 3. Update baseline
make test-all BASELINE=1

# 4. Compare with previous baseline
bash scripts/compare-test-results.sh
```

### Initial Setup

```bash
# 1. Build image
make build

# 2. Run all tests
make test-all
# Installs all tools, runs all tests, creates snapshot

# 3. Create baseline
make test-all BASELINE=1

# 4. Verify
bash scripts/verify-baseline.sh
```

## Related Documentation

- [README.md](../README.md): General repository information

