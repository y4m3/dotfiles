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

Delta automatically activates when using git commands. For usage examples and navigation keys, refer to the [Delta documentation](https://github.com/dandavison/delta#usage).

**Repository-specific features:**
- Tokyo Night theme applied
- Side-by-side view enabled
- Navigate mode enabled
- Line numbers displayed
