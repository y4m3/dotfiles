# Alacritty (Terminal Emulator)

## Official Documentation

https://alacritty.org/

## Installation

- **Alacritty**: Download `.msi` installer from https://alacritty.org/ (Windows host)
- **Themes**: `git clone https://github.com/alacritty/alacritty-theme.git %APPDATA%\alacritty\themes` (Windows)

## Configuration Files

**Windows**:
- Base: `%APPDATA%\alacritty\alacritty.toml` (manual setup required)
- Machine-specific: `%APPDATA%\alacritty\alacritty.local.toml` (managed by chezmoi)

**Linux/macOS**:
- Base: `~/.config/alacritty/alacritty.toml` (manual setup required)
- Machine-specific: `~/.config/alacritty/alacritty.local.toml` (managed by chezmoi)

**Templates**:
- Example: `home/dot_config/alacritty/alacritty.toml.example` (reference template)
- Machine-specific: `home/dot_config/alacritty/create_alacritty.local.toml.tmpl` (chezmoi managed)

**Note**: `alacritty.toml` is **not managed by chezmoi** to avoid overwriting Windows-specific paths. Copy `alacritty.toml.example` to your platform's config location and customize as needed. `alacritty.local.toml` is machine-specific and managed by chezmoi (created once, not overwritten). Add `[terminal.shell]` section in `alacritty.local.toml` for machine-specific shell configuration.

## Initial Setup

1. **Copy the example configuration**:
   ```bash
   # Linux/macOS
   cp home/dot_config/alacritty/alacritty.toml.example ~/.config/alacritty/alacritty.toml
   
   # Windows (PowerShell)
   Copy-Item home\dot_config\alacritty\alacritty.toml.example $env:APPDATA\alacritty\alacritty.toml
   ```

2. **Update theme import path** in `alacritty.toml`:
   - **Windows**: `"%APPDATA%\\alacritty\\themes\\themes\\tokyo_night_storm.toml"`
   - **Linux/macOS**: `"~/.config/alacritty/themes/themes/tokyo_night_storm.toml"`

3. **Run `chezmoi apply`** to create `alacritty.local.toml` (machine-specific config)

4. **Edit `alacritty.local.toml`** to add `[terminal.shell]` section (see below)

## Machine-specific Shell Configuration

Add `[terminal.shell]` section in `alacritty.local.toml`:

**WSL**:
```toml
[terminal.shell]
program = "C:\\Windows\\System32\\wsl.exe"
args = ["-d", "dev", "--cd", "~", "bash", "-ic", "'zellij attach --create main'"]
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
