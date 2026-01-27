# Terminal Environment

## Emulators

### WezTerm (Primary)

Concise notes focused on environment-specific configuration. Refer to official docs for general usage.

**Official Documentation**: https://wezterm.org/

**Installation**: Managed by `run_onchange_client_ubuntu_200-wezterm.sh.tmpl`. Configuration: `~/.config/wezterm/wezterm.lua`.

#### Environment-specific Configuration

- **Version**: nightly (from apt.fury.io/wez repository)
- **LEADER Key**: `Ctrl+\` (1000ms timeout, see [keybinding-design.md](../keybinding-design.md) for unified layer design)
- **Keybindings**: All pane/tab operations use LEADER prefix (Layer 2 in keybinding-design.md)
- **Mux Server**: systemd user service (`wezterm-mux.service`)

#### Local Configuration (`wezterm.local.lua`)

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

#### Critical Warning: Shell Integration Issue

**WezTerm apt package breaks bash/starship prompts on WSL/Ubuntu.**

**What Happens**

When you install `wezterm-nightly` via apt, it automatically installs `/etc/profile.d/wezterm.sh` which:

- Overwrites `PROMPT_COMMAND`
- Injects OSC 133 escape sequences into `PS1`
- Breaks starship/bash prompts **even when not using WezTerm terminal**
- Affects all login shells including WSL via `wsl.exe`

**Symptoms**

- PS1 displays as unescaped string literals
- Prompt looks broken in PowerShell -> `wsl.exe -d Ubuntu`
- starship prompt fails to render correctly
- Issues appear even when using Windows Terminal or other terminals

**Solution**

The install script automatically disables shell integration:

```bash
sudo mv /etc/profile.d/wezterm.sh /etc/profile.d/wezterm.sh.disabled
```

**After apt upgrade**

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

#### WSL SSH Session: cursor command

When SSH'd into WSL, the `cursor` command doesn't work. Use the function defined in `~/.bashrc.local`:

```bash
cursor .           # Open current directory
cursor file.txt    # Open specific file
```

### Alacritty (Alternative)

**Official Documentation**: https://alacritty.org/

**Installation**:
- **Alacritty**: Download `.msi` installer from https://alacritty.org/ (Windows host)
- **Themes**: `git clone https://github.com/alacritty/alacritty-theme.git %APPDATA%\alacritty\themes` (Windows)

#### Configuration Files

**Windows** (manual setup required):
- Base: `%APPDATA%\alacritty\alacritty.toml` - copy from repo and update paths
- Machine-specific: `%APPDATA%\alacritty\alacritty.local.toml`

**Linux/macOS** (managed by chezmoi):
- Base: `~/.config/alacritty/alacritty.toml` - auto-deployed via `chezmoi apply`
- Machine-specific: `~/.config/alacritty/alacritty.local.toml` - created once, not overwritten

**Source files**:
- Base: `home/dot_config/alacritty/alacritty.toml`
- Machine-specific: `home/dot_config/alacritty/create_alacritty.local.toml.tmpl`

**Note**: On Linux/macOS, `alacritty.toml` is managed by chezmoi. On Windows, manual setup is required because chezmoi runs inside WSL. Machine-specific settings (especially `[terminal.shell]`) should be added to `alacritty.local.toml`, which is imported last and takes priority.

#### Initial Setup

**Linux/macOS**

1. **Run `chezmoi apply`** - `alacritty.toml` and `alacritty.local.toml` are auto-deployed
2. **Edit `alacritty.local.toml`** to add `[terminal.shell]` section (see below)

**Windows (manual setup)**

1. **Copy the base configuration**:
   ```powershell
   Copy-Item home\dot_config\alacritty\alacritty.toml $env:APPDATA\alacritty\alacritty.toml
   ```

2. **Update import paths** in `alacritty.toml` to Windows format:
   - Theme: `"%APPDATA%\\alacritty\\themes\\themes\\tokyo_night_storm.toml"`
   - Local: `"%APPDATA%\\alacritty\\alacritty.local.toml"`

3. **Run `chezmoi apply`** (in WSL) to create `alacritty.local.toml` template, then copy to Windows.
   Replace `<distro>` with your WSL distribution name (e.g., `Ubuntu`) and `<user>` with your Linux username:
   ```powershell
   Copy-Item \\wsl$\<distro>\home\<user>\.config\alacritty\alacritty.local.toml $env:APPDATA\alacritty\
   ```

4. **Edit `alacritty.local.toml`** to add `[terminal.shell]` section (see below)

#### Machine-specific Shell Configuration

Add `[terminal.shell]` section in `alacritty.local.toml`:

**WSL**:
```toml
[terminal.shell]
program = "C:\\Windows\\System32\\wsl.exe"
args = ["-d", "dev", "--cd", "~", "bash", "-lc", "'zellij attach --create main'"]
```

**Linux**:
```toml
[terminal.shell]
program = "/usr/bin/bash"
args = ["-l"]
```

**macOS**:
```toml
[terminal.shell]
program = "/bin/zsh"
args = ["-l"]
```

## Multiplexers

### Zellij (Primary)

Concise notes focused on environment-specific configuration. Refer to official docs for general usage.

**Official Documentation**: https://github.com/zellij-org/zellij

**Installation**: Managed by Nix Home Manager (`home/dot_config/nix/home.nix`).

#### Environment-specific Configuration

| Setting | Value |
|---------|-------|
| Theme | `tokyo-night-storm` |
| Default Layout | `default` |
| Pane Frames | Disabled (`pane_frames false`) |
| Scroll Buffer | 100,000 lines |
| Mouse Mode | Enabled |
| Copy on Select | Enabled |
| Session Serialization | Enabled (for session resurrection) |
| Auto Layout | Enabled |
| Startup Tips | Disabled |

#### Keybindings Overview

This configuration uses **Ctrl+a** as the Leader key (tmux-style), with `clear-defaults=true` to define all keybindings explicitly.

For detailed keybinding documentation including cross-tool consistency with GlazeWM and WezTerm, see [keybinding-design.md](../keybinding-design.md).

**Quick Reference (Ctrl+a -> key)**

| Key | Action |
|-----|--------|
| h/j/k/l | Pane navigation |
| H/J/K/L | Pane resize |
| i/o | Previous/Next tab |
| 1-9 | Go to tab N |
| c | New tab |
| v/s | Split right/down |
| x/X | Close pane/tab |
| f | Toggle fullscreen |
| w | Toggle floating panes |
| [ | Scroll/Copy mode |
| / | Search mode |
| d | Detach session |
| a | Send Ctrl+a to terminal |

**Mode Navigation**

The configuration starts in **Normal mode**. From Normal mode:

- **Ctrl+a** enters Tmux mode (Leader mode for most operations)
- Operations in Tmux mode return to Normal mode automatically

From Tmux mode, switch to other modes for detailed operations:

| Key | Mode |
|-----|------|
| t | Tab mode |
| r | Resize mode |
| p | Pane mode |
| m | Move mode |
| g | Locked mode (all keys pass through) |
| Esc/Enter | Return to Normal mode |

**Locked mode**: All keys pass through to the terminal. Exit with `Ctrl+g`.

#### Configuration Files

| File | Purpose |
|------|---------|
| `~/.config/zellij/config.kdl` | Main configuration (keybindings, settings) |
| `~/.config/zellij/layouts/default.kdl` | Default layout (with compact-bar plugin) |

### tmux (Alternative)

Concise notes focused on environment-specific behavior. See official docs for usage.

**Official Documentation**: https://github.com/tmux/tmux

**Installation**: Managed by Nix Home Manager (`home/dot_config/nix/home.nix`). Configuration: `home/dot_tmux.conf`.

#### Environment-specific Configuration

- Vim-style navigation:
  - `prefix + h/j/k/l` to move, `prefix + H/J/K/L` to resize
- Splits:
  - `prefix + |` (vertical), `prefix + -` (horizontal)
- Clipboard integration:
  - OSC 52 passthrough enabled (`set -g set-clipboard on`)
  - vi copy-mode: `y`/`Enter` copies via `~/.local/bin/clipboard-copy`
  - `prefix + P` pastes from system clipboard via `~/.local/bin/clipboard-paste`
  - Works across WSL, SSH, X11/Wayland environments
- Theme:
  - Tokyo Night colors for status bar and pane borders
- Features:
  - Mouse enabled, vi copy-mode, 256 colors, renumber windows

#### Session Management

| Key | Action |
|-----|--------|
| d | Detach session |
| S | Rename session |
| N | New session (name prompt) |
| F | tmux-sessionizer (project picker) |
| G | agent-deck (AI agent session manager) |
| w | Session/window tree |

#### tmux-sessionizer

Fuzzy finder for switching between project directories and tmux sessions.

- Launch: `prefix + F` or `tm` alias
- Search targets:
  1. Existing tmux sessions (displayed with `[session]` prefix)
  2. Repositories managed by ghq
  3. Additional directories specified in `create_dirs`

**Config file**: `~/.config/tmux-sessionizer/create_dirs`

```
# One directory per line
# ~ is expanded to $HOME
# Lines starting with # are comments

~/.local/share/chezmoi
~/repos
~/projects
```

#### Popup Edit

Quick text input via Neovim in a floating popup window. Useful for composing messages, commands, or notes.

- Launch: `prefix + e`
- Workflow:
  1. Opens Neovim in popup window
  2. Write text, then save and quit (`:wq`)
  3. Text is automatically sent to the original pane
- File storage: `$XDG_RUNTIME_DIR/popup-edit/`

**Use cases:**
- Compose long commands before execution
- Write commit messages with full editor support
- Quick notes or text snippets

#### gitmux

Displays Git information (branch, divergence, flags) in the tmux status bar.

- Config: `~/.config/gitmux/.gitmux.conf`

#### Modular Configuration

| File | Purpose |
|------|---------|
| `appearance.conf` | Theme, colors, status bar |
| `keybindings.conf` | Key mappings |
| `plugins.conf` | TPM plugin configuration |
| `submodes.conf` | Resize/Tab/Pane/Move mode keys |

## See Also

- [Keybinding Design](../keybinding-design.md) - Layer 2 (WezTerm) and Layer 3 (Zellij)
