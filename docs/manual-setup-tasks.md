# Manual Setup Tasks

Manual tasks to complete after `chezmoi apply`. These require interactive user input or machine-specific configuration.

## Quick Checklist

### Required
- [ ] **Git Configuration** - Edit `~/.gitconfig.local` with your name and email

### Recommended
- [ ] **Alacritty Terminal** - Install on Windows host (WSL users)
- [ ] **Alacritty Configuration** - Configure `[terminal.shell]` in `%APPDATA%\alacritty\alacritty.local.toml`
- [ ] **GitHub CLI Authentication** - Run `gh auth login`
- [ ] **Fonts Installation** - Install UDEV Gothic font (see [Fonts](post-setup/fonts.md))
- [ ] **Docker Group** - Log out and log back in (or run `newgrp docker`) after Docker installation

### Optional
- [ ] **User-specific Bash Settings** - Customize `~/.bashrc.local`
- [ ] **SSH Key Generation** - Generate SSH keys if needed (see [Security](tools/security.md))
- [ ] **Python Visualization Fonts** - Install Noto Sans JP and Roboto (see [Fonts](post-setup/fonts.md))

---

## 1. Git Configuration (Required)

Edit `~/.gitconfig.local` and uncomment:
```ini
[user]
    name = Your Name
    email = your.email@example.com
```

Verify: `git config user.name && git config user.email`

---

## 2. Alacritty Terminal Installation (Windows Host)

**Note**: For WSL users, install on Windows host, not inside WSL.

Download from https://alacritty.org/

See [Alacritty Documentation](tools/alacritty.md) for details.

---

## 3. Alacritty Configuration (Windows Host)

**Configuration files**:
- Base: `%APPDATA%\alacritty\alacritty.toml`
- Machine-specific: `%APPDATA%\alacritty\alacritty.local.toml`

**Steps**:
1. Install themes: `git clone https://github.com/alacritty/alacritty-theme.git $env:APPDATA\alacritty\themes`
2. Copy example config: `Copy-Item home\dot_config\alacritty\alacritty.toml.example $env:APPDATA\alacritty\alacritty.toml`
3. Update theme import path in `alacritty.toml` to Windows format: `"%APPDATA%\\alacritty\\themes\\themes\\tokyo_night_storm.toml"`
4. Run `chezmoi apply` to create `alacritty.local.toml` (machine-specific config)
5. Add WSL shell configuration in `alacritty.local.toml`:
   ```toml
   [terminal.shell]
   program = "C:\\Windows\\System32\\wsl.exe"
   args = ["-d", "dev", "--cd", "~", "bash", "-ic", "'zellij attach --create main'"]
   ```

See [Alacritty Documentation](tools/alacritty.md) for details.

---

## 4. GitHub CLI Authentication

Run `gh auth login` and follow the prompts.

Verify: `gh auth status`

See [GitHub Tools Documentation](tools/github-tools.md) for security best practices.

---

## 5. Fonts Installation

See [Fonts Documentation](post-setup/fonts.md) for installation instructions.

---

## 6. Docker Group

After Docker installation, log out and log back in (or run `newgrp docker`).

Verify: `docker ps`

See [Docker Documentation](tools/docker.md) for details.

---

## 7. User-specific Bash Settings

Edit `~/.bashrc.local` to add personal settings:
```bash
export ENABLE_CD_LS=1
alias myalias='command'
export MY_VAR="value"
```

**Note**: `.bashrc.local` is managed as `create_.bashrc.local.tmpl` (created only on first apply) and is not overwritten by chezmoi. You can freely edit this file for personal customizations.

---

## 8. SSH Key Generation

Generate SSH key:
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```

See [Security Best Practices](tools/security.md) for details.

