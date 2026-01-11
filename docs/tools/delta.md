# delta

Syntax-highlighting pager for git diff with side-by-side view.

## Official Documentation

https://github.com/dandavison/delta

## Installation

Managed by Nix Home Manager (`home/dot_config/nix/home.nix`). Configured in `~/.gitconfig`.

## Environment-specific Configuration

Configured in global git config (applied by dotfiles):
- `core.pager = delta`
- `interactive.diffFilter = delta --color-only`
- `delta.features = tokyo-night`
- `delta.navigate = true`, `delta.side-by-side = true`, `delta.line-numbers = true`
