# Security Best Practices

This document describes security measures implemented in this dotfiles repository and recommendations for credential management.

## Automatic Security Enforcement

This dotfiles automatically enforces strict file permissions on credential files and directories via `~/.bashrc.d/75-security-permissions.sh`. This script runs on each shell startup and ensures proper permissions are set.

## Protected Files and Directories

### GitHub CLI (`gh`)

- **Directory**: `~/.config/gh` → 700 (owner only)
- **File**: `~/.config/gh/hosts.yml` → 600 (owner read/write only)

**Best Practices:**
- Use fine-grained Personal Access Tokens (PATs) instead of classic tokens
- Set expiration dates for tokens
- Limit access to specific repositories when possible
- Regularly rotate tokens: `gh auth refresh`

### SSH Keys

- **Directory**: `~/.ssh` → 700 (owner only)
- **Private keys**: `~/.ssh/id_rsa`, `~/.ssh/id_ed25519`, etc. → 600 (owner read/write only)
- **Config file**: `~/.ssh/config` → 600 (owner read/write only)
- **Authorized keys**: `~/.ssh/authorized_keys` → 600 (owner read/write only)
- **Known hosts**: `~/.ssh/known_hosts` → 644 (readable by group/others is acceptable)
- **Public keys**: `~/.ssh/*.pub` → 644 (public keys can be readable)

**Best Practices:**
- Use strong passphrases for SSH keys
- Prefer Ed25519 keys over RSA: `ssh-keygen -t ed25519 -C "your_email@example.com"`
- Use SSH agent for passphrase caching: `ssh-add ~/.ssh/id_ed25519`
- Regularly rotate keys and remove unused keys from servers

### Git Credential Helper

- **File**: `~/.git-credentials` → 600 (owner read/write only)

**Automatic Configuration:**

This dotfiles automatically configures Git credential helper via `~/.gitconfig`:
- Uses `cache` helper (credentials stored in memory, not on disk)
- Default timeout: 1800 seconds (30 minutes) - configured in `~/.bashrc.local`
- Configurable via `GIT_CREDENTIAL_CACHE_TIMEOUT` environment variable

**Customizing Timeout:**

The timeout is configured in `~/.bashrc.local` (created on first `chezmoi apply`). Simply edit the value:

```bash
# In ~/.bashrc.local
export GIT_CREDENTIAL_CACHE_TIMEOUT=1800  # 30 minutes (default)
# or
export GIT_CREDENTIAL_CACHE_TIMEOUT=3600  # 1 hour
# or
export GIT_CREDENTIAL_CACHE_TIMEOUT=900   # 15 minutes
```

After editing `~/.bashrc.local`, run `chezmoi apply` to update the Git configuration. The new timeout will be applied to the credential helper.

**Note:** The environment variable must be set before running `chezmoi apply`. If you edit `~/.bashrc.local` in a new shell session, make sure to source it or restart your shell before running `chezmoi apply`.

**Best Practices:**

- Default timeout (3600 seconds / 1 hour) is suitable for most development workflows
- For shared machines or high-security environments, consider shorter timeouts (e.g., 900 seconds / 15 minutes)
- For personal development machines, longer timeouts (e.g., 7200 seconds / 2 hours) may be more convenient

**Avoid `store` helper** unless necessary, as it saves credentials in plain text. If you must use it:

```bash
git config --global credential.helper store
# Ensure ~/.git-credentials has 600 permissions (automatically enforced)
```

**For GitHub authentication**, prefer Personal Access Tokens (PATs) over passwords:
- Create PAT: GitHub Settings → Developer settings → Personal access tokens
- Use PAT as password when prompted by Git

### npm/yarn Credentials

- **File**: `~/.npmrc` → 600 (only if contains authentication tokens)

**Best Practices:**
- Use `npm login` to authenticate (stores token securely)
- For CI/CD, use environment variables instead of `.npmrc` files
- Regularly rotate npm tokens

### Docker Credentials

- **Directory**: `~/.docker` → 700 (owner only)
- **File**: `~/.docker/config.json` → 600 (only if contains authentication)

**Best Practices:**
- Use `docker login` to authenticate with registries
- For production, use credential helpers or secrets management
- Regularly rotate registry credentials

### Python Credentials

- **File**: `~/.pypirc` → 600 (owner read/write only)
- **File**: `~/.pip/pip.conf` → 600 (only if contains passwords/tokens)

**Best Practices:**
- Use API tokens instead of passwords
- For PyPI, use `twine` with API tokens
- Store credentials in environment variables when possible

### Rust Credentials

- **Directory**: `~/.cargo` → 700 (only if credentials file exists)
- **File**: `~/.cargo/credentials` → 600 (owner read/write only)
- **File**: `~/.cargo/credentials.toml` → 600 (owner read/write only)

**Best Practices:**
- Use `cargo login` to authenticate with crates.io
- Store API tokens securely
- Regularly rotate tokens

### GPG Keys

- **Directory**: `~/.gnupg` → 700 (owner only)
- **Private keys**: `~/.gnupg/secring.gpg`, `~/.gnupg/private-keys-v1.d/` → 600/700

**Best Practices:**
- Use strong passphrases for GPG keys
- Use `gpg-agent` for passphrase caching
- Regularly rotate keys
- Back up keys securely

## Verifying Permissions

Check current permissions on credential files:

```bash
# GitHub CLI
ls -ld ~/.config/gh
ls -l ~/.config/gh/hosts.yml

# SSH
ls -ld ~/.ssh
ls -l ~/.ssh/id_*

# Git credentials
ls -l ~/.git-credentials 2>/dev/null || echo "No git-credentials file"

# Other tools
ls -l ~/.npmrc ~/.docker/config.json ~/.pypirc ~/.cargo/credentials 2>/dev/null
```

Expected permissions:
- Directories: `drwx------` (700)
- Credential files: `-rw-------` (600)
- Public keys: `-rw-r--r--` (644)

## Manual Permission Fix

If permissions are incorrect, fix them manually:

```bash
# GitHub CLI
chmod 700 ~/.config/gh
chmod 600 ~/.config/gh/hosts.yml

# SSH
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/authorized_keys

# Git credentials
chmod 600 ~/.git-credentials

# Other tools
chmod 600 ~/.npmrc ~/.docker/config.json ~/.pypirc ~/.cargo/credentials
chmod 700 ~/.docker ~/.cargo ~/.gnupg
```

Or simply restart your shell - permissions will be automatically corrected by `75-security-permissions.sh`.

## Additional Security Recommendations

1. **Use environment variables** for secrets when possible (especially in CI/CD)
2. **Never commit credentials** to version control
3. **Use secret management tools** (e.g., HashiCorp Vault, AWS Secrets Manager) for production
4. **Regularly audit** active credentials and revoke unused ones
5. **Enable two-factor authentication** (2FA) wherever possible
6. **Use fine-grained permissions** - grant only the minimum required access
7. **Set expiration dates** on tokens and credentials
8. **Monitor access logs** for suspicious activity

## References

- [GitHub CLI Security](github-tools.md#authentication-and-security)
- [SSH Key Management](https://www.ssh.com/academy/ssh/key)
- [Git Credential Storage](https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage)
- [OWASP Credential Storage](https://cheatsheetseries.owasp.org/cheatsheets/Credential_Storage_Cheat_Sheet.html)

