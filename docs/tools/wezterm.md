# wezterm

Concise notes focused on environment-specific configuration. Refer to official docs for general usage.

## Official Documentation

https://wezterm.org/

## Installation

Managed by `run_onchange_client_ubuntu_200-wezterm.sh.tmpl`. Configuration: `~/.config/wezterm/wezterm.lua`.

## Environment-specific Configuration

- **Version**: nightly (from apt.fury.io/wez repository)
- **LEADER Key**: `Ctrl+\` (avoids conflicts with zellij which uses Alt)
- **Keybindings**: All pane/tab operations use LEADER prefix
- **Mux Server**: systemd user service (`wezterm-mux.service`)

## Local Configuration (`wezterm.local.lua`)

All workspace and connection settings are configured in `~/.config/wezterm/wezterm.local.lua` using the `environments` array:

```lua
environments = {
    {
        key = "1",                    -- LEADER + key
        workspace_name = "wsl",       -- Workspace name
        connection = "connect",       -- "local" | "connect" | "ssh"
        remote_address = "127.0.0.1",
        username = "dev",
        is_default = true,
    },
    {
        key = "2",
        workspace_name = "posh",
        connection = "local",
        args = { "pwsh.exe", "-NoLogo" },
    },
}
```

**connection types:**
- `"local"` - Run local command (uses `args`)
- `"connect"` - WezTerm SSH domain (`wezterm connect <workspace_name>`)
- `"ssh"` - System SSH command (`ssh user@host`)

## Critical Warning: Shell Integration Issue

**WezTerm apt package breaks bash/starship prompts on WSL/Ubuntu.**

### What Happens

When you install `wezterm-nightly` via apt, it automatically installs `/etc/profile.d/wezterm.sh` which:

- Overwrites `PROMPT_COMMAND`
- Injects OSC 133 escape sequences into `PS1`
- Breaks starship/bash prompts **even when not using WezTerm terminal**
- Affects all login shells including WSL via `wsl.exe`

### Symptoms

- PS1 displays as unescaped string literals
- Prompt looks broken in PowerShell → `wsl.exe -d Ubuntu`
- starship prompt fails to render correctly
- Issues appear even when using Windows Terminal or other terminals

### Solution

The install script automatically disables shell integration:

```bash
sudo mv /etc/profile.d/wezterm.sh /etc/profile.d/wezterm.sh.disabled
```

### After apt upgrade

Shell integration may be restored after `apt upgrade`. If prompts break again:

```bash
# Quick fix
sudo mv /etc/profile.d/wezterm.sh /etc/profile.d/wezterm.sh.disabled

# Permanent fix (prevents restoration on upgrade)
sudo dpkg-divert --add --rename \
  --divert /etc/profile.d/wezterm.sh.distrib \
  /etc/profile.d/wezterm.sh
sudo ln -s /dev/null /etc/profile.d/wezterm.sh
```

## WSL SSH Session: cursor command

When SSH'd into WSL, the `cursor` command doesn't work. Use the function defined in `~/.bashrc.local`:

```bash
cursor .           # Open current directory
cursor file.txt    # Open specific file
```
