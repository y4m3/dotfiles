# Security Best Practices

This document describes security measures implemented in this dotfiles repository.

## Automatic Security Enforcement

This dotfiles automatically enforces strict file permissions on credential files and directories via `~/.bashrc.d/030-security-permissions.sh`. This script runs on each shell startup and ensures proper permissions are set.

## Protected Files and Directories

### GitHub CLI (`gh`)

- **Directory**: `~/.config/gh` → 700
- **File**: `~/.config/gh/hosts.yml` → 600

**Commands:**
- Rotate tokens: `gh auth refresh`

### SSH Keys

- **Directory**: `~/.ssh` → 700
- **Private keys**: `~/.ssh/id_*` → 600
- **Config file**: `~/.ssh/config` → 600
- **Public keys**: `~/.ssh/*.pub` → 644

**Commands:**
- Generate Ed25519 key: `ssh-keygen -t ed25519 -C "your_email@example.com"`
- Add to SSH agent: `ssh-add ~/.ssh/id_ed25519`

### Git Credential Helper

This dotfiles automatically configures Git credential helper via `~/.gitconfig`:
- Uses `cache` helper (credentials cached in memory)
- Default timeout: 1800 seconds (30 minutes) - configured in `~/.bashrc.local`
- Configurable via `GIT_CREDENTIAL_CACHE_TIMEOUT` environment variable

**Customizing Timeout:**

Edit `~/.bashrc.local`:
```bash
export GIT_CREDENTIAL_CACHE_TIMEOUT=1800  # 30 minutes (default)
```

After editing, run `chezmoi apply` to update the Git configuration.

**Platform compatibility:** On non-Linux systems, add to `~/.gitconfig.local`:
```gitconfig
# macOS
[credential]
    helper = osxkeychain

# Windows
[credential]
    helper = manager-core
```

### Other Credentials

- **npm/yarn**: `~/.npmrc` → 600 (if contains tokens)
- **Docker**: `~/.docker` → 700, `~/.docker/config.json` → 600
- **Python**: `~/.pypirc` → 600, `~/.pip/pip.conf` → 600 (if contains passwords)
- **Rust**: `~/.cargo` → 700, `~/.cargo/credentials*` → 600
- **GPG**: `~/.gnupg` → 700

## Verifying Permissions

```bash
# Check permissions
ls -ld ~/.config/gh ~/.ssh ~/.docker ~/.cargo ~/.gnupg
ls -l ~/.config/gh/hosts.yml ~/.ssh/id_* ~/.git-credentials 2>/dev/null
```

Expected: Directories `drwx------` (700), credential files `-rw-------` (600), public keys `-rw-r--r--` (644)

## Manual Permission Fix

```bash
chmod 700 ~/.config/gh ~/.ssh ~/.docker ~/.cargo ~/.gnupg
chmod 600 ~/.config/gh/hosts.yml ~/.ssh/id_* ~/.ssh/config ~/.git-credentials
```

Or restart your shell - permissions will be automatically corrected by `030-security-permissions.sh`.
