# Pre-Commit Verification Checklist

This document provides a checklist for verifying the repository before committing changes.

## Quick Static Checks (Host Machine)

These checks can be run on the host machine without Docker:

### 1. Configuration File Syntax Check

```bash
bash scripts/check-config-syntax.sh
```

This checks:
- Bash configuration files (`.bashrc`, `.bash_profile`, `.bashrc.d/*.sh`)
- TOML configuration files (starship, yazi)
- KDL configuration files (zellij)
- YAML configuration files (lazygit, lazydocker)

**Expected result**: All files pass static syntax check

### 2. Shell Script Linting

```bash
make lint
```

This runs `shellcheck` and `shfmt` on all shell scripts.

## Docker-Based Verification

These checks require Docker and may take time. For detailed information, see [Testing Guide](testing-guide.md).

### 3. Change Detection Tests

```bash
make test
```

Runs tests for changed files only. See [Testing Guide - Change Detection Test](testing-guide.md#1-change-detection-test-make-test) for details.

### 4. Full Test Suite

```bash
make test-all
```

Runs all tests and creates a snapshot. **Warning**: May take 30+ minutes depending on network conditions and GitHub API rate limits. See [Testing Guide - All Tests](testing-guide.md#2-all-tests-make-test-all) for details.

### 5. Interactive Verification

```bash
make dev
```

Starts an interactive shell in the Docker container. See [Testing Guide - Interactive Verification](testing-guide.md#step-10-interactive-verification) for detailed verification steps.

**Quick Checklist:**
- [ ] Configuration files exist and are valid (`~/.config/zellij/config.kdl`, `~/.config/starship.toml`, etc.)
- [ ] Tools start without errors (`zellij --version`, `starship prompt`, etc.)
- [ ] PATH includes `~/.local/bin` and `~/.cargo/bin`
- [ ] Tools are available via `command -v`

## Common Issues

For detailed troubleshooting information, see:
- [Testing Guide - Troubleshooting](testing-guide.md#troubleshooting)
- [Troubleshooting Guide](troubleshooting.md)

**Quick fixes:**
- **GitHub API Rate Limit**: Ensure `gh` CLI is authenticated on host (`gh auth login`)
- **Docker Container Hangs**: Stop running containers (`docker ps -q | xargs -r docker stop`) and run `make clean`
- **Configuration File Errors**: Check syntax with `zellij setup --check` or `starship prompt`

## Recommended Pre-Commit Workflow

1. **Quick static checks** (always):
   ```bash
   bash scripts/check-config-syntax.sh
   make lint
   ```

2. **Change detection tests** (before committing):
   ```bash
   make test
   ```

3. **Full test suite** (before major changes or releases):
   ```bash
   make test-all
   ```

4. **Interactive verification** (as needed):
   ```bash
   make dev
   # Verify tools and configurations interactively
   ```

## Notes

- Static checks are fast and can be run frequently
- Docker-based tests require network access and may take time
- Interactive verification is recommended for configuration changes
- Full test suite should be run before major commits or releases

