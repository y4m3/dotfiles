# CLI Tools

Modern command-line tools managed by Nix Home Manager (`home/dot_config/nix/home.nix`).

## File Operations

### bat

**Official**: https://github.com/sharkdp/bat

A `cat` clone with syntax highlighting and Git integration.

**Environment-specific**:
- Tokyo Night themes installed via `.chezmoiexternal.toml`
- Default: `tokyonight_storm` (override via `BAT_THEME` in `~/.bashrc.local`)
- Smart `cat` function: uses bat for interactive viewing, real cat for pipes/redirects

### eza

**Official**: https://github.com/eza-community/eza

Modern replacement for `ls` with colors and icons.

**Environment-specific**:
- Basic aliases: `ls`, `ll`, `la`, `tree`
- Icons and colors enabled automatically

### fd

**Official**: https://github.com/sharkdp/fd

Fast alternative to `find` with intuitive syntax.

**Environment-specific**:
- `.fdignore` includes core exclusions: `.git`, `node_modules`, `target`, `dist`, `build`, `__pycache__`, `*.pyc`

### ripgrep (rg)

**Official**: https://github.com/BurntSushi/ripgrep

Fast recursive grep with smart defaults.

**Environment-specific**:
- `.ripgreprc` includes: `--smart-case`, `--hidden`, and core exclusions (`.git`, `node_modules`, `target`, `dist`, `build`, `__pycache__`, `*.pyc`)

### yazi

**Official**: https://github.com/sxyazi/yazi

Terminal file manager with image preview support.

**Installation**:
- Binary: Managed by Nix Home Manager
- Plugins: Installed via `run_after_onchange_client_ubuntu_220-yazi-plugins.sh.tmpl`
- Configuration: `~/.config/yazi/`

**Environment-specific**:
- Minimal configuration: `$EDITOR` integration for text files, directory navigation
- Keybindings, theme, and other settings use defaults

### trash-cli

**Official**: https://github.com/andreafrancia/trash-cli

Safe file deletion using the FreeDesktop.org trash specification.

**Environment-specific aliases:**

| Command | Action |
|---------|--------|
| `tp <file>` | Move file to trash (trash-put) |
| `del <file>` | Permanent deletion with confirmation |
| `trash` / `tl` | List trash contents |

**Note:** `rm` is aliased to show a reminder to use `tp` instead. Use `del` for permanent deletion.

**Recovery:**

```bash
trash-list                    # List trashed files with paths
trash-restore                 # Interactive restore
```

## Navigation & Search

### fzf

**Official**: https://github.com/junegunn/fzf

Command-line fuzzy finder for interactive selection.

**Environment-specific**:
- Bash integration: `Ctrl+R` (history search), `Ctrl+T` (file insert), `Alt+C` (cd)
- Default command: Uses `fd` if available (faster and respects `.fdignore`)
- UI options: `--height 40% --reverse --border`
- Preview: File preview with `bat` (if available), directory preview with `eza` (if available)

**Troubleshooting**:
- **Key bindings not working**: Check if `.fzf.bash` is loaded: `[ -f ~/.fzf.bash ] && source ~/.fzf.bash`. Reload shell: `exec bash -l`

### zoxide

**Official**: https://github.com/ajeetdsouza/zoxide

Smarter `cd` command that learns your habits.

**Environment-specific**:
- Command alias is `j` (not `z`)
- Optional auto-ls via `ENABLE_CD_LS=1` in `.bashrc.local`
- Exclusion paths via `_ZO_EXCLUDE_DIRS`, echo behavior via `_ZO_ECHO`

**Troubleshooting**:
- **j command not found**: Use in interactive shells. Reload: `exec bash -l` or `source ~/.bashrc.d/910-zoxide.sh`

## Completions

### carapace

**Official**: https://carapace.sh/

Shell-agnostic completion framework providing intelligent completions across bash, zsh, fish, and more.

**Environment-specific:**
- Enabled via `~/.bashrc.d/170-completion.sh`
- Provides completions for 1000+ commands
- Falls back to bash-completion for unsupported commands

## Display

### starship

**Official**: https://starship.rs/

Cross-shell prompt with git status and context awareness.

**Environment-specific**:
- Prompt shows git status, python venv, command duration, jobs
- Enable via `PROMPT_STYLE=starship` in local bash config

### glow

**Official**: https://github.com/charmbracelet/glow

Terminal-based Markdown reader with style support.

**Configuration**: `~/.config/glow/glow.yml` (generated from `home/dot_config/glow/create_glow.yml.tmpl`)

**Default Settings**:
- `style: "dark"` - Dark theme (matches tokyo-night)
- `mouse: true` - Mouse wheel support in TUI mode
- `pager: true` - Use pager to display markdown
- `width: 80` - Word wrap at 80 columns

**Troubleshooting**:
- **Command not found**: Check PATH: `echo "$PATH" | grep ".local/bin"`. Reload shell: `exec bash -l`
- **Configuration not applied**: Check file exists: `ls -la ~/.config/glow/glow.yml`. Apply chezmoi: `chezmoi apply ~/.config/glow/glow.yml`

### tldr

**Official**: https://tldr.sh/

Community-maintained simplified man pages with practical examples.

```bash
tldr tar      # Quick examples for tar command
tldr --update # Update local cache
```
