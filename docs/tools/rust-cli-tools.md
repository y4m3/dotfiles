# bat, eza, fd, ripgrep, starship, zoxide

Rust-based CLI tools for enhanced terminal experience.

All tools installed via cargo in `run_once_210-shell-cargo-tools.sh.tmpl`.

## bat

**Official**: https://github.com/sharkdp/bat

**Environment-specific**:
- Tokyo Night themes installed via `run_once_215-shell-bat-tokyonight.sh`
- Default: `tokyonight_night` (override via `BAT_THEME` in `~/.bashrc.local`)
- Smart `cat` function: uses bat for interactive viewing, real cat for pipes/redirects

## eza

**Official**: https://github.com/eza-community/eza

**Environment-specific**:
- Basic aliases: `ls`, `ll`, `la`, `tree`
- Icons and colors enabled automatically

## fd

**Official**: https://github.com/sharkdp/fd

**Environment-specific**:
- `.fdignore` includes core exclusions: `.git`, `node_modules`, `target`, `dist`, `build`, `__pycache__`, `*.pyc`

## ripgrep (rg)

**Official**: https://github.com/BurntSushi/ripgrep

**Environment-specific**:
- `.ripgreprc` includes: `--smart-case`, `--hidden`, and core exclusions (`.git`, `node_modules`, `target`, `dist`, `build`, `__pycache__`, `*.pyc`)

## starship

**Official**: https://starship.rs/

**Environment-specific**:
- Prompt shows git status, python venv, command duration, jobs
- Enable via `PROMPT_STYLE=starship` in local bash config

## zoxide

**Official**: https://github.com/ajeetdsouza/zoxide

**Environment-specific**:
- Command alias is `j` (not `z`)
- Optional auto-ls via `ENABLE_CD_LS=1`
