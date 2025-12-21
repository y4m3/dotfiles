# Cargo Tools

Fast CLI tools written in Rust. Fast and feature-rich alternatives to traditional Unix commands.

## Installed Tools

### bat

Alternative to `cat`. File viewer with syntax highlighting and Git integration.

```bash
bat file.rs           # Display with syntax highlighting
bat -n file.py        # Show line numbers
bat --diff file.txt   # Display in Git diff style
```

**Custom configuration**: Configured in `~/.config/bat/config` (managed by this dotfiles)

- Theme: Default (or choose with `bat --list-themes`)
- Line numbers: Always displayed
- Git integration: Enabled

### eza

Alternative to `ls`. Supports tree display, Git integration, and icon display.

```bash
eza                   # Colorful list
eza -l                # Detailed display
eza -T                # Tree display
eza --git             # Git status display
```

**Alias**: This dotfiles aliases `ls` → `eza` (in `60-utils.sh`)

### fd-find

Alternative to `find`. Intuitive syntax and fast search.

```bash
fd pattern            # Filename search
fd -e rs              # Extension filter
fd -H hidden          # Search hidden files too
fd -t d config        # Search directories only
```

**Configuration**: Set global exclusion patterns in `~/.fdignore` (managed by this dotfiles)

### ripgrep (rg)

Alternative to `grep`. Blazingly fast code search tool.

```bash
rg pattern            # Recursive search
rg -i pattern         # Case-insensitive
rg -t rust pattern    # File type filter
rg -g '*.md' pattern  # Glob pattern
```

**Configuration**: Configured in `~/.ripgreprc` (managed by this dotfiles)
**Note**: If using `alias grep='rg'` in interactive shells, use `command grep` in scripts

### starship

Cross-shell prompt. Displays Git status, language versions, execution time, etc.

```bash
# Prompt automatically applied on shell startup
```

**Configuration**: Detailed customization possible in `~/.config/starship.toml` (managed by this dotfiles)

### zoxide

Fast directory jumping tool. See [`docs/tools/zoxide.md`](./zoxide.md) for details.

## Installation Method

This dotfiles installs in the following order:

1. `run_once_100-runtimes-rust.sh`: Install Rustup + Cargo
2. `run_once_210-shell-cargo-tools.sh`: Install all Cargo tools

```bash
# To reinstall individually
cargo install bat eza fd-find ripgrep starship zoxide
```

## grep Alias Caution

If `alias grep='rg'` is set in interactive shells, traditional options like `grep -E` will be interpreted as `rg` and may error.

**Solution**: Use `command grep` in scripts or when accurate behavior is needed:

```bash
echo "$PATH" | command grep -E '/cargo/bin'
```

All test scripts in this dotfiles use `command grep`.

## Troubleshooting

### Cargo Tools Not Found

Check if `~/.cargo/bin` is in PATH:

```bash
echo "$PATH" | tr : '\n' | grep cargo
```

If not included, reload in login shell:

```bash
exec bash -l
```

### Updating Rust Version

```bash
rustup update stable
cargo install --force bat eza fd-find ripgrep starship zoxide
```
