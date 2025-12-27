# delta

Syntax-highlighting pager for git diff with side-by-side view.

## Official Documentation

https://github.com/dandavison/delta

## Installation

Managed by `run_once_320-devtools-delta.sh.tmpl`:
- Downloads latest release from GitHub
- Installs to `~/.local/bin/delta`
- Configured in `~/.gitconfig`

## Configuration

### Git Integration

Configured in global git config (applied by dotfiles):
- `core.pager = delta`
- `interactive.diffFilter = delta --color-only`
- `delta.features = tokyo-night`
- `delta.navigate = true`, `delta.side-by-side = true`, `delta.line-numbers = true`

### Tokyo Night Theme

Custom color scheme matching the overall dotfiles theme:
- File headers: `#7aa2f7` (blue)
- Hunk headers: `#bb9af7` (purple)
- Added lines: green tones
- Removed lines: red tones
- Line numbers with distinct colors

## Usage

Delta automatically activates when using git commands:

```bash
git diff              # View unstaged changes
git diff --cached     # View staged changes
git log -p            # View commit history with diffs
git show <commit>     # View specific commit
```

### Navigation

- `n` / `N`: Jump to next/previous file
- `Ctrl+F` / `Ctrl+B`: Page forward/backward
- `q`: Quit

## Features

- **Side-by-side view**: Compare changes visually
- **Line numbers**: Easy reference
- **Syntax highlighting**: Language-aware colors
- **Git integration**: Works with all git commands
- **Navigate mode**: Jump between files easily
