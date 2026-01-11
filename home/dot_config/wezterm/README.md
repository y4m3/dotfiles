# WezTerm Local Configuration

This document explains how to configure `~/.wezterm.local.lua` for different connection types and environments.

## Official Documentation

- [Multiplexing overview](https://wezterm.org/multiplexing.html)
- [SSH domains](https://wezterm.org/config/lua/SshDomain.html)
- [WSL domains](https://wezterm.org/config/lua/config/wsl_domains.html)
- [SSH configuration](https://wezterm.org/ssh.html)

## Connection Types Overview

| Type | Description | Clipboard | Persistence |
|------|-------------|-----------|-------------|
| `local` | Run local command (wsl.exe, pwsh.exe, cmd.exe) | ✅ Full (win32yank) | ❌ None |
| `connect` | SSH domain with multiplexer (session survives restart) | ⚠️ OSC 52, paste: Ctrl+Shift+V | ✅ Yes |
| `ssh` | Plain SSH connection (simple, no multiplexer) | ⚠️ OSC 52, paste: Ctrl+Shift+V | ❌ None |

## Clipboard Behavior

The clipboard behavior depends on **HOW** you connect, not WHERE.

### "local" connection

```
Process tree:
  WezTerm.exe → wsl.exe → bash → nvim → win32yank.exe
                                            ↓
                                   Windows Clipboard ✅
```

**Why it works:**
wsl.exe inherits WezTerm's Windows session context. All child processes can access Windows resources.

**Clipboard operations:**
- `yy` (yank) → ✅ Works (win32yank.exe)
- `p` (paste) → ✅ Works (win32yank.exe)
- Ctrl+Shift+V → ✅ Works (terminal paste)

### "connect" or "ssh" connection

```
Process tree:
  WezTerm.exe ──SSH──→ sshd → bash → nvim
                         │
                  [isolated session]
                         ↓
                 win32yank.exe ❌ (cannot reach Windows)
```

**Why clipboard is limited:**
SSH creates an isolated session without Windows desktop access. This is identical to SSH'ing to any remote server.

**Clipboard operations:**
- `yy` (yank) → ✅ Works (OSC 52 escape sequence via terminal)
- `p` (paste) → ❌ Does NOT work (use Ctrl+Shift+V instead)
- Ctrl+Shift+V → ✅ Works (terminal paste)

**OSC 52 works because:**
The escape sequence travels through the SSH tunnel to WezTerm, which then writes to the Windows clipboard.

## Choosing the Right Connection

| Use Case | Recommended Connection |
|----------|------------------------|
| Long-running work, survive restarts | `connect` (accept Ctrl+Shift+V for paste) |
| Frequent copy-paste, short sessions | `local` + wsl.exe |
| One-off remote server connection | `ssh` |
| Need both persistence AND clipboard | Configure both, switch as needed |

## Configuration Schema

```lua
return {
  environments = {
    {
      key = "1",                    -- LEADER + key for quick switch
      workspace_name = "myws",      -- Display name (freely chosen)
      connection = "local|connect|ssh",

      -- For "local":
      args = { "pwsh.exe", "-NoLogo" },

      -- For "connect":
      remote_address = "hostname",  -- From ~/.ssh/config or IP
      username = "user",
      default_prog = { "/bin/bash", "-l" },  -- Optional

      -- For "ssh":
      remote_address = "hostname",
      username = "user",

      is_default = true,            -- Start with this workspace
    },
  },

  font = {
    family = "Font Name",
    size = 12,
    weight = "Regular",  -- Optional
  },
}
```

## Sample Configurations

### Sample 1: WSL via wsl.exe (Full Clipboard)

Best for: Frequent copy-paste operations
- Clipboard: `yy` and `p` both work with Windows clipboard
- Persistence: None (close WezTerm = lose session)

```lua
return {
  environments = {
    {
      key = "q",
      workspace_name = "ubuntu",
      connection = "local",
      args = { "wsl.exe", "-d", "Ubuntu", "--", "/bin/bash", "-l" },
      is_default = true,
    },
  },
  font = { family = "JetBrains Mono", size = 11 },
}
```

### Sample 2: PowerShell

Best for: Windows-native development

```lua
return {
  environments = {
    {
      key = "w",
      workspace_name = "powershell",
      connection = "local",
      args = { "pwsh.exe", "-NoLogo" },
      is_default = true,
    },
  },
  font = { family = "JetBrains Mono", size = 11 },
}
```

### Sample 3: SSH Domain with Multiplexer (Session Persistence)

Best for: Long-running work that survives WezTerm restart
- Clipboard: Use Ctrl+Shift+V for paste (`yy` works via OSC 52)
- Persistence: Yes (sessions survive WezTerm restart)

**Prerequisites:**

1. SSH server in WSL:
   ```bash
   sudo apt install openssh-server
   sudo service ssh start
   ```

2. `~/.ssh/config` (Windows side):
   ```
   Host wsl
     HostName 127.0.0.1
     User yourusername
     Port 22
   ```

```lua
return {
  environments = {
    {
      key = "q",
      workspace_name = "dev",
      connection = "connect",
      remote_address = "wsl",    -- Matches Host in ~/.ssh/config
      username = "yourusername",
      default_prog = { "/bin/bash", "-l" },
      is_default = true,
    },
  },
  font = { family = "JetBrains Mono", size = 11 },
}
```

### Sample 4: Plain SSH (Simple Remote Connection)

Best for: One-off connections to remote servers
- Clipboard: Use Ctrl+Shift+V for paste
- Persistence: None

```lua
return {
  environments = {
    {
      key = "r",
      workspace_name = "remote",
      connection = "ssh",
      remote_address = "myserver.example.com",
      username = "admin",
    },
  },
  font = { family = "JetBrains Mono", size = 11 },
}
```

### Sample 5: Hybrid (Best of Both Worlds)

Configure both approaches and switch based on your current needs:
- LEADER+q → SSH session (persistent, use Ctrl+Shift+V for paste)
- LEADER+a → Local WSL (full clipboard, no persistence)
- LEADER+w → PowerShell

```lua
return {
  environments = {
    {
      key = "q",
      workspace_name = "dev-persistent",
      connection = "connect",
      remote_address = "wsl",
      username = "dev",
      is_default = true,
    },
    {
      key = "a",
      workspace_name = "dev-clipboard",
      connection = "local",
      args = { "wsl.exe", "-d", "Ubuntu", "--", "/bin/bash", "-l" },
    },
    {
      key = "w",
      workspace_name = "powershell",
      connection = "local",
      args = { "pwsh.exe", "-NoLogo" },
    },
  },
  font = { family = "JetBrains Mono", size = 11 },
}
```
