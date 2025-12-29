# bat, eza, fd, ripgrep, starship, zoxide

Rust-based CLI tools for enhanced terminal experience.

## Overview

All tools installed via cargo in `run_once_210-shell-cargo-tools.sh.tmpl`.

## bat

Cat clone with syntax highlighting and git integration.

**Official**: https://github.com/sharkdp/bat

**Environment-specific**:
- Theme set to OneHalfDark
- Style includes header, grid, numbers

For usage and configuration options, refer to the [bat documentation](https://github.com/sharkdp/bat).

## eza

Modern ls replacement with git integration and icons.

**Official**: https://github.com/eza-community/eza

**Environment-specific**:
- Icons enabled automatically
- Time style: long-iso
- Custom colors applied via shell env

For usage and configuration options, refer to the [eza documentation](https://github.com/eza-community/eza).

## fd

Fast, user-friendly alternative to find.

**Official**: https://github.com/sharkdp/fd

**Environment-specific**:
- `.fdignore` includes common dev directories (git/node/target/pycache)

For usage and configuration options, refer to the [fd documentation](https://github.com/sharkdp/fd).

## ripgrep (rg)

Fast grep alternative with smart defaults.

**Official**: https://github.com/BurntSushi/ripgrep

**Environment-specific**:
- Smart-case search and hidden files enabled
- Max columns tuned; excludes aligned with `.fdignore`

For usage and configuration options, refer to the [ripgrep documentation](https://github.com/BurntSushi/ripgrep).

## starship

Fast, customizable cross-shell prompt.

**Official**: https://starship.rs/

**Environment-specific**:
- Prompt shows git status, python venv, command duration, jobs
- Enable via `PROMPT_STYLE=starship` in local bash config

For configuration options, refer to the [starship documentation](https://starship.rs/config/).

## zoxide

Smarter cd command that learns your habits.

**Official**: https://github.com/ajeetdsouza/zoxide

**Environment-specific**:
- Command alias is `j` (not `z`)
- Optional auto-ls via `ENABLE_CD_LS=1`
- Excludes common temp/cache directories

For usage and configuration options, refer to the [zoxide documentation](https://github.com/ajeetdsouza/zoxide).
