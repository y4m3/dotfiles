# fzf (Fuzzy Finder)

Concise notes focused on environment-specific configuration. Refer to official docs for general usage.

## Official Documentation

https://github.com/junegunn/fzf

## Installation

- Managed by `run_once_200-shell-fzf.sh.tmpl`

## Environment-specific Configuration

- Bash integration default keys: `Ctrl+R` (history search), `Ctrl+T` (file insert), `Alt+C` (cd)
- No explicit custom settings for fzf itself (uses upstream defaults)

**Repository-recommended settings** (configurable in `.bashrc.local`):

```bash
# Default command (when using fd)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# Default options
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Preview command
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
```

For all configuration options, see the [fzf documentation](https://github.com/junegunn/fzf#environment-variables).

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

Setting `FZF_DEFAULT_COMMAND` to use fd improves search speed and filtering. See the [fd documentation](https://github.com/sharkdp/fd#configuration) for fd configuration options.

### Update

See the [fzf installation guide](https://github.com/junegunn/fzf#upgrading-fzf) for update instructions.

## Integration with Other Tools

This dotfiles integrates fzf with other tools. For integration examples and patterns, refer to:
- [fzf documentation](https://github.com/junegunn/fzf#examples) for general integration patterns
- Each tool's documentation for tool-specific integration options
