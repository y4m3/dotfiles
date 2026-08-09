# Claude Instructions for This Repository

This chezmoi-managed dotfiles repository supports Ubuntu/WSL2 (Nix Home Manager) and Windows (winget).

Design principle: the terminal is a cockpit for AI agents (herdr + Claude Code).
Add a tool only when you need it (pull-based): one line in `home/.chezmoidata/packages.yaml`.

## File Editing Rules

### Single Source of Truth

- All tools live in `home/.chezmoidata/packages.yaml` (nix / apt / winget groups).
  Never hand-write a package list anywhere else. Templates generate all configs from this file.
- One binary supplier: Nix supplies Linux (nvim disables Mason).
  The Windows layer is minimal: terminal, git, and shell via winget. chezmoi does not deploy the nvim config on Windows.

### Chezmoi Template Syntax

Files ending in `.tmpl` use Go template syntax:
- `{{ .chezmoi.os }}` - OS name ("linux", "windows", "darwin")
- `{{ .is_wsl }}` - Boolean for WSL environment

### OS Guards

Use the empty-template pattern to skip files entirely:
```
{{- if eq .chezmoi.os "windows" -}}
# Windows-only content here
{{- end -}}
```

### Script Naming Convention

```
run_{once,onchange}[_after]_{number}-{name}.{sh,ps1}.tmpl
```

The `after` attribute comes AFTER `onchange` (`run_onchange_after_` is valid;
`run_after_onchange_` is NOT chezmoi syntax and silently breaks ordering).
OS selection happens inside the template via guards, not in the filename.

Examples (real files):
- `run_once_020-ubuntu-install-nix.sh.tmpl`
- `run_onchange_after_210-ubuntu-home-manager.sh.tmpl`

Verify parsing with `chezmoi managed --include=scripts`. Rendered names must
look like `010-ubuntu-apt-packages.sh`; chezmoi strips all attributes.

### `.chezmoiignore`

Patterns match TARGET paths; chezmoi strips attributes before it matches
them. Patterns never match source names like `run_once_...sh.tmpl`.

### Cross-Platform Code

The only config that runs on both platforms is wezterm. When branching by OS:
```lua
local is_win = wezterm.target_triple:find("windows") ~= nil
```

## Verification

Always verify changes before committing:

```bash
./lint                       # shellcheck + shfmt + template sanity
chezmoi diff                 # Show what would change
chezmoi apply --dry-run -v   # Verbose dry run
chezmoi apply                # Apply changes
```

## Coding Standards

### Shell Scripts (Linux)
- Use `set -euo pipefail`
- 2-space indentation (Google Shell Style Guide)

### PowerShell Scripts (Windows)
- Use `$ErrorActionPreference = 'Stop'`
- Use `Set-StrictMode -Version Latest`

### Lua (Neovim)
- Follow existing LazyVim patterns
- Use `opts = function(_, opts)` for extending defaults

## Git Commit Rules

- Follow Conventional Commits **without scope**: `type: message`
- Types: `feat`, `bug`, `chore`
- Write in English
- Check `git log` for style reference

## Warnings

- **DO NOT** modify file permissions on `install.sh` (causes issues on Windows)
- **DO NOT** use `echo` or bash commands for user communication - use direct text output
- **DO NOT** create new documentation files unless explicitly requested
- **ALWAYS** test cross-platform compatibility when editing shared configs (wezterm)
- **ALWAYS** use `chezmoi apply --dry-run` before applying changes
