# Configuration Guide

This guide explains the configuration policy and customization methods for this dotfiles repository. Assumes host application; Docker is for validation only.

## Quick apply (host)

Install chezmoi and apply (replace `$GITHUB_USERNAME`):

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply $GITHUB_USERNAME
```

Update later:

```bash
chezmoi update
```

For Docker validation, refer to "Docker (optional)" section in README.

## Design Principles

### 1. Non-destructive Customization

User-specific settings are written in `.bashrc.local`. This file:

- Managed as `create_.bashrc.local.tmpl` (created only on first apply)
- Not overwritten by chezmoi
- Freely editable by users

```bash
# ~/.bashrc.local example
export ENABLE_CD_LS=1           # Auto ls after cd
export FZF_DEFAULT_OPTS='...'   # fzf customization
alias mycommand='...'            # Personal aliases
```

### 2. Modular bashrc

Settings are split and managed in `~/.bashrc.d/` directory:

- `10-user-preferences.sh`: User settings (locale, editor, etc.)
- `20-paths.sh`: PATH management
- `30-completion.sh`: Command completion
- `40-runtimes.sh`: Language runtime initialization (Rust, Node.js, etc.)
- `60-utils.sh`: Tool initialization and aliases

Each file operates independently and can be disabled or customized as needed.

### 3. Idempotency and Error Handling

All `run_once_*` scripts:

- Use `set -euo pipefail` for strict error checking
- Detect existing installations and avoid re-execution
- Provide clear log messages (`==> Starting`, `✓ Completed`)
- APT operations use `DEBIAN_FRONTEND=noninteractive` for non-interactive mode

## Customization Best Practices

### Adding Environment Variables

Write in `.bashrc.local`:

```bash
export MY_CUSTOM_VAR="value"
export PATH="/my/custom/path:$PATH"
```

### Adding Aliases

Write in `.bashrc.local`:

```bash
alias myalias='command'
```

See your shell's documentation for alias syntax and best practices.

### Adding Functions

Write in `.bashrc.local`:

```bash
myfunction() {
    # function body
}
```

See your shell's documentation for function syntax.

### Tool-specific Configuration

Configuration files for each tool:

- `~/.config/bat/config`: bat configuration
- `~/.config/starship.toml`: starship configuration
- `~/.fdignore`: fd-find exclusion patterns
- `~/.ripgreprc`: ripgrep configuration
- `~/.gitconfig`: Git and ghq configuration (includes credential helper with configurable timeout)

These are all managed by chezmoi and generated from `home/dot_config/` or `home/create_*`.

**Git Credential Helper:**

Git credential helper is automatically configured with `cache` helper. The timeout is configured in `~/.bashrc.local` (default: 1800 seconds / 30 minutes). To customize, edit `GIT_CREDENTIAL_CACHE_TIMEOUT` in `~/.bashrc.local` and run `chezmoi apply`. See [Security Best Practices](tools/security.md#git-credential-helper) for details.

## PATH Management

### Priority Order

This dotfiles builds PATH in the following order:

1. `~/.local/bin` (highest priority)
2. `~/.cargo/bin` (Rust tools)
3. `~/go/bin` (Go tools, ghq, etc.)
4. System default PATH

### Adding Custom Paths

Add in `.bashrc.local`:

```bash
# Add to front (highest priority)
export PATH="/my/priority/path:$PATH"

# Add to end (low priority)
export PATH="$PATH:/my/optional/path"
```

## Locale Settings

### Default Configuration

- `LANG=en_US.UTF-8`: System messages in English
- `LC_COLLATE=en_US.UTF-8`: Locale-specific sort order

### Customization

Change in `.bashrc.local`:

```bash
# Use a different locale for everything
export LANG=fr_FR.UTF-8
export LC_COLLATE=fr_FR.UTF-8

# Use English for everything
export LANG=en_US.UTF-8
export LC_COLLATE=en_US.UTF-8
```

## Shell Prompt Customization

### Starship (Default)

This dotfiles uses starship by default. The configuration file is at `~/.config/starship.toml`.

**Repository-specific customization:**
- Tokyo Night theme applied
- Git integration enabled
- Command duration display enabled

For configuration options and syntax, refer to the [Starship documentation](https://starship.rs/config/).

### Alternative Prompts

If not using starship, select a script from `~/.bash_prompt.d/`:

```bash
# Switch in .bashrc.local
source ~/.bash_prompt.d/bare.sh       # Simple prompt
source ~/.bash_prompt.d/enhanced.sh   # Git-integrated prompt
```

## Testing and Debugging

### Validating Configuration

```bash
# Test configuration in container
make test

# Manual verification in interactive shell
make dev
```

### Debug Mode

Debugging bashrc:

```bash
# Add to .bashrc.local
set -x  # Trace commands
# ... write configuration ...
set +x  # End trace
```

Verify individual module loading:

```bash
bash -x ~/.bashrc.d/20-paths.sh
```

## Cheat Sheet

Summary of repository-specific customizations:

```bash
# ~/.bashrc.local

# zoxide: Auto ls after cd (repository-specific feature)
export ENABLE_CD_LS=1

# fzf: Repository-recommended settings
# See https://github.com/junegunn/fzf#environment-variables for all options
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"

# fd: Default command for fzf
# See https://github.com/sharkdp/fd#configuration for fd configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# Custom PATH
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
```
