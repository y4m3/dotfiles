# Alacritty (Terminal Emulator)

## Official Documentation

https://alacritty.org/

## Installation

- **Alacritty**: Download `.msi` installer from https://alacritty.org/ (Windows host)
- **Themes**: `git clone https://github.com/alacritty/alacritty-theme.git %APPDATA%\alacritty\themes` (Windows)

## Configuration Files

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

## Initial Setup

### Linux/macOS

1. **Run `chezmoi apply`** - `alacritty.toml` and `alacritty.local.toml` are auto-deployed
2. **Edit `alacritty.local.toml`** to add `[terminal.shell]` section (see below)

### Windows (manual setup)

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

## Machine-specific Shell Configuration

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
