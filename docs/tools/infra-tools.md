# Infrastructure Tools

Concise notes focused on environment-specific configuration. Refer to official docs for general usage.

## Container

### Docker

**Documentation**: https://docs.docker.com/engine/ | https://docs.docker.com/compose/

**Installation**: Via `run_onchange_client_ubuntu_120-docker.sh.tmpl` using official script.

**Container Detection:**

The installation script automatically detects if running inside a container (checks for `/.dockerenv` or cgroup) and skips Docker installation. This allows the same dotfiles to work on both host systems and inside containers.

**Important**: Always run `chezmoi apply` on the host system. When using dotfiles inside a Docker container, Docker commands should target the host's Docker daemon (if needed via socket mount).

**User Group:**

The script adds the current user to the `docker` group, allowing Docker commands without `sudo`. After installation:

```bash
newgrp docker  # Activate group in current session (or log out/in)
docker ps      # Verify access
```

**Why this matters**: Without group membership, every `docker` command requires `sudo`, which breaks many development tools and scripts.

### lazydocker

**Documentation**: https://github.com/jesseduffield/lazydocker

**Installation**: Nix Home Manager (`home/dot_config/nix/home.nix`)

**Config**: `~/.config/lazydocker/config.yml`

Terminal UI for Docker management. View containers, images, volumes, and logs in a single interface.

**Environment-specific settings:**

- Log timestamps disabled for cleaner output
- Other settings use defaults

**Usage:**

```bash
lazydocker  # Launch TUI
# Navigation: hjkl or arrow keys
# [: Previous tab, ]: Next tab
# d: Remove container/image, D: Force remove
# e: Hide/show stopped containers
```

## System Monitoring

### btop

**Documentation**: https://github.com/aristocratos/btop

**Installation**: Nix Home Manager (`home/dot_config/nix/home.nix`)

**Config**: `~/.config/btop/btop.conf`

Resource monitor with CPU, memory, disk, network, and process information.

**Environment-specific settings:**

- Theme: Tokyo Night Storm (`tokyo-storm`) - consistent with terminal/editor theme
- Truecolor enabled for accurate theme colors
- Theme background enabled (uses theme's background color)
- 2000ms update interval (balanced between responsiveness and CPU usage)

**Usage:**

```bash
btop  # Launch monitor
# Navigation: hjkl or arrow keys
# f: Filter processes
# k: Kill process (sends SIGTERM)
# m: Menu for theme and options
```

### lnav

**Documentation**: https://lnav.org/

**Installation**: Nix Home Manager (`home/dot_config/nix/home.nix`)

Log file navigator with automatic format detection, syntax highlighting, and filtering.

**Environment-specific settings:**

- Uses defaults (no custom configuration)
- Binary is statically linked (no additional dependencies)

**Usage:**

```bash
lnav /var/log/syslog           # View single log
lnav /var/log/*.log            # View multiple logs (merged timeline)
lnav -r /var/log/              # Recursively load directory

# In lnav:
# /: Search
# n/N: Next/previous match
# i: Toggle histogram view
# Tab: Switch between views
```

**Supported formats**: syslog, Apache, nginx, Docker, journald, and many others (auto-detected).
