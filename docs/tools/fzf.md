# fzf (Fuzzy Finder)

Concise notes focused on environment-specific configuration. Refer to official docs for general usage.

## Official Documentation

https://github.com/junegunn/fzf

## Installation

- Managed by `run_once_200-shell-fzf.sh.tmpl`

## Environment-specific Configuration

- Bash integration default keys: `Ctrl+R` (history search), `Ctrl+T` (file insert), `Alt+C` (cd)
- No explicit custom settings for fzf itself (uses upstream defaults)
- Other tools like bat/fd can be used together, but the single source of truth is each tool's documentation/template

Recommended settings in this dotfiles (configurable in `.bashrc.local`):

```bash
# Default command (when using fd)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# Default options
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Preview command
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
```

### Example Aliases

```bash
# Navigate to repository (ghq + fzf)
alias repo='cd $(ghq list -p | fzf)'

# Kill process
alias fkill='ps aux | fzf | awk "{print \$2}" | xargs kill'

# Git branch switching
alias gb='git branch | fzf | xargs git checkout'
```

## Installation Method

This dotfiles uses the official installation script:

```bash
# Automatically executed in run_once_200-shell-fzf.sh
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
```

**Options**:
- `--all`: Enable all shell integrations (bash key bindings, completion, etc.)
- `--no-update-rc`: Skip automatic bashrc updates (for manual management)

## Troubleshooting

### Key Bindings Not Working

Check if `.fzf.bash` is loaded:

```bash
# Usually automatically loaded from ~/.bashrc
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
```

Reload in login shell:

```bash
exec bash -l
```

### Combining with fd

Setting `FZF_DEFAULT_COMMAND` to use fd improves search speed and filtering:

```bash
# Add to .bashrc.local
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
```

### Update

```bash
cd ~/.fzf
git pull
./install --all
```

## Integration with Other Tools

### Integration with ghq

Fast repository search and navigation:

```bash
cd $(ghq list -p | fzf)
```

### Integration with zoxide

Select directory jump candidates with fzf:

```bash
zi() {
  local dir
  dir=$(zoxide query -l | fzf) && cd "$dir"
}
```

### Integration with bat

Speed up preview display:

```bash
fzf --preview 'bat --color=always --style=numbers {}'
```
