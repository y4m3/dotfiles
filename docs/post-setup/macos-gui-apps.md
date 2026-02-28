# macOS GUI Applications

GUI applications for macOS are managed via Homebrew Bundle (`brew bundle`).
These scripts are executed during normal `chezmoi apply`.

## Managed Brewfiles

- Common apps: `~/.config/homebrew/Brewfile.common`
- Private apps: `~/.config/homebrew/Brewfile.private` (enabled when `DOTFILES_INSTALL_PRIVATE_APPS=true`)

## Common Apps (Brewfile.common)

- JankyBorders (`felixkratz/formulae/borders`)
- SketchyBar (`felixkratz/formulae/sketchybar`)
- macSKK
- Visual Studio Code
- Google Chrome
- Firefox
- Heynote

## Theme Config (Tokyo Night)

- `~/.config/sketchybar/colors.sh`
- `~/.config/sketchybar/sketchybarrc`
- `~/.config/borders/bordersrc`

### SketchyBar Layout

- Left: AeroSpace workspace, current media title, play/pause control
- Right: date/time, network, CPU, memory
- Center: unused (notch-safe for MacBook Air M2 camera area)

## Service Management (chezmoi)

- `chezmoi apply` runs `~/.chezmoiscripts/run_after_onchange_client_darwin_213-bars-services.sh.tmpl`
- The script ensures `brew services start sketchybar` and `brew services start borders`
- It also runs `sketchybar --reload` and `borders` to apply updated config

**Note**: WezTerm is installed manually (not via `Brewfile.common`).

## Private Apps (Brewfile.private)

- Brave Browser
- Linear
- Todoist
- Zotero
- Raindrop.io

## Enable Private Apps

```bash
export DOTFILES_INSTALL_PRIVATE_APPS=true
chezmoi apply
```

To persist:

```bash
echo 'export DOTFILES_INSTALL_PRIVATE_APPS=true' >> ~/.zshrc.local
```
