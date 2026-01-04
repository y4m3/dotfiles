# glow (Markdown Reader)

Concise notes focused on environment-specific configuration. Refer to official docs for general usage.

## Official Documentation

https://github.com/charmbracelet/glow

## Installation

Installed via `run_onchange_client_ubuntu_370-glow.sh.tmpl` from GitHub releases. Installs to `~/.local/bin/glow`.

## Environment-specific Configuration

Configuration: `~/.config/glow/glow.yml` (generated from `home/dot_config/glow/create_glow.yml.tmpl`).

**Default Settings**:
- `style: "dark"` - Dark theme (matches tokyo-night)
- `mouse: true` - Mouse wheel support in TUI mode
- `pager: true` - Use pager to display markdown
- `width: 80` - Word wrap at 80 columns

## Troubleshooting

- **Command not found**: Check PATH: `echo "$PATH" | grep ".local/bin"`. Reload shell: `exec bash -l`
- **Configuration not applied**: Check file exists: `ls -la ~/.config/glow/glow.yml`. Apply chezmoi: `chezmoi apply ~/.config/glow/glow.yml`

