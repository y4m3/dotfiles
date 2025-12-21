# fzf (Fuzzy Finder)

Interactive fuzzy finder for command line. Interactively search files, command history, processes, and more.

## Basic Usage

### File Search

```bash
# Search files under current directory
fzf

# Open selected file
vim $(fzf)

# Search with preview
fzf --preview 'bat --color=always {}'
```

### Command History Search

```bash
# Search history with Ctrl+R (automatically configured in bash)
# Press Ctrl+R in terminal to launch fzf
```

### Combination with Pipes

```bash
# Select from list
ls | fzf

# Process selection
ps aux | fzf

# Git branch selection
git branch | fzf | xargs git checkout
```

## Key Bindings (Default)

- `Ctrl+R`: Command history search
- `Ctrl+T`: File search (insert selected path)
- `Alt+C`: Directory navigation (cd with fuzzy search)

These are automatically configured when fzf is installed.

## Custom Configuration

### Environment Variables

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
