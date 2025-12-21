# Configuration Guide

This guide explains the configuration policy and customization methods for this dotfiles repository.

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
alias gst='git status'
alias dc='docker compose'
alias k='kubectl'
```

### Adding Functions

Write in `.bashrc.local`:

```bash
# Useful function examples
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Select Git branch with fzf
gb() {
    git branch | fzf | xargs git checkout
}
```

### Tool-specific Configuration

Configuration files for each tool:

- `~/.config/bat/config`: bat configuration
- `~/.config/starship.toml`: starship configuration
- `~/.fdignore`: fd-find exclusion patterns
- `~/.ripgreprc`: ripgrep configuration
- `~/.gitconfig`: Git and ghq configuration

These are all managed by chezmoi and generated from `home/dot_config/` or `home/create_*`.

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
- `LC_COLLATE=ja_JP.UTF-8`: Japanese-compatible sort order

### Customization

Change in `.bashrc.local`:

```bash
# Use Japanese for everything
export LANG=ja_JP.UTF-8

# Use English for everything
unset LC_COLLATE
```

## Shell Prompt Customization

### Starship (Default)

This dotfiles uses starship by default. Customize in `~/.config/starship.toml`:

```toml
# Switch to simple prompt
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"

# Customize Git display
[git_branch]
symbol = "🌱 "
```

For details, refer to [starship documentation](https://starship.rs/config/).

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

Summary of commonly used settings:

```bash
# ~/.bashrc.local

# zoxide: Auto ls after cd
export ENABLE_CD_LS=1

# fzf: Enable preview
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"

# fd: Default command for fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# Aliases
alias repo='cd $(ghq list -p | fzf)'
alias gst='git status'
alias dc='docker compose'

# Custom PATH
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
```
