# Windows GUI Applications

GUI applications for Windows are automatically installed via winget by chezmoi scripts.

## Automatic Installation

The following applications are installed automatically by `chezmoi apply`:

### Common Apps (210-winget-gui-apps.ps1)

**Tools:**
- Git, WezTerm, AutoHotkey, PowerToys, KeePassXC

**Browsers:**
- Google Chrome, Mozilla Firefox

**Editors:**
- Neovim, Visual Studio Code, Cursor, Zed, Obsidian, Heynote

**Window Manager:**
- GlazeWM, Zebar

**Launcher:**
- ueli

**IME:**
- CorvusSKK

### Private Apps (211-winget-gui-private.ps1)

Enabled by setting `DOTFILES_INSTALL_PRIVATE_APPS=true` before `chezmoi init`:

```powershell
$env:DOTFILES_INSTALL_PRIVATE_APPS = "true"
chezmoi init
chezmoi apply
```

**Browsers:**
- LibreWolf, Brave

**Proton Suite:**
- ProtonPass, ProtonMail, ProtonDrive, ProtonVPN

**Task Management:**
- Linear, Todoist

**Library:**
- Zotero

## Adding New Apps

To add a new application, edit the appropriate script in `home/.chezmoiscripts/`:

1. Find the winget ID: `winget search <app-name>`
2. Add the ID to the `$apps` array in the script
3. Run `chezmoi apply`
