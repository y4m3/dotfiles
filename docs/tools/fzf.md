# fzf (Fuzzy Finder)

Concise notes focused on environment-specific configuration. Refer to official docs for general usage.

## Official Documentation

https://github.com/junegunn/fzf

## Installation

Managed by `run_onchange_client_ubuntu_200-fzf.sh.tmpl`

## Environment-specific Configuration

- Bash integration: `Ctrl+R` (history search), `Ctrl+T` (file insert), `Alt+C` (cd)
- Default command: Uses `fd` if available (faster and respects `.fdignore`)
- UI options: `--height 40% --reverse --border`
- Preview: File preview with `bat` (if available), directory preview with `eza` (if available)

## Troubleshooting

- **Key bindings not working**: Check if `.fzf.bash` is loaded: `[ -f ~/.fzf.bash ] && source ~/.fzf.bash`. Reload shell: `exec bash -l`
