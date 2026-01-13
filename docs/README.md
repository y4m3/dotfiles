# Documentation

This directory contains documentation for a highly personalized chezmoi dotfiles environment.

These configurations are tailored to a specific workflow and may not be immediately intuitive or applicable to other setups. The documentation serves as a reference for understanding design decisions and customizations unique to this environment.

## Warning

**WezTerm apt package breaks bash/starship prompts on WSL/Ubuntu.** If your prompt displays as unescaped string literals after `apt upgrade`, see [tools/terminals.md](tools/terminals.md#critical-warning-shell-integration-issue) for the fix.

## Quick Links

- **[Installed Tools](installed-tools.md)** - Complete list of tools managed by Nix Home Manager and chezmoi
- **[Manual Setup Tasks](manual-setup-tasks.md)** - Tasks requiring user input after `chezmoi apply`
- **[Keybinding Design](keybinding-design.md)** - Unified keybinding system across GlazeWM, WezTerm, Zellij, and LazyVim

## Structure

- **`tools/`** - Tool-specific configurations and environment notes
  - `chezmoi.md` - Dotfiles management
  - `security.md` - GPG, SSH key management
  - `editors.md` - Neovim, Vim, Japanese input
  - `terminals.md` - WezTerm, Alacritty, Zellij, tmux
  - `git-tools.md` - delta, lazygit, gh, ghq
  - `cli-tools.md` - bat, eza, fd, rg, starship, zoxide, fzf, yazi, glow
  - `dev-tools.md` - jq, just, deno, prettier, markdownlint, mermaid, ast-grep, shellcheck, shfmt, yq, Node.js, direnv, uv, pyright, ruff
  - `infra-tools.md` - Docker, lazydocker, btop, lnav
- **`templates/`** - Reusable configuration templates (e.g., `.envrc` examples)
- **`post-setup/`** - Post-installation guides requiring manual steps (fonts, Windows GUI apps)
