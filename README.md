# Dotfiles

These dotfiles configure an agent-first development environment.
The primary platform is Ubuntu on WSL2.
Windows gets a minimal configuration.

Managed with [chezmoi](https://www.chezmoi.io/) and [Nix Home Manager](https://nix-community.github.io/home-manager/).

## Design rules

- The terminal is a cockpit for AI agents ([herdr](https://herdr.dev/), Claude Code).
  A tool gets a place only if it helps you drive agents, examine their output, or make changes by hand.
- One file lists all tools: `home/.chezmoidata/packages.yaml`.
  To add a tool, add one line to this file.
- One binary supplier: Nix supplies Linux.
  The Windows layer is minimal (terminal, git, shell via winget); development tools live in WSL.
- `flake.lock` and `lazy-lock.json` are in git.
  Versions change only when you commit a change.
- herdr is the terminal multiplexer. Its config lives in `~/.config/herdr/config.toml`.
  tmux is the fallback.
- Colors come from the terminal ANSI palette (`bat`, `delta`, `herdr`, tmux).
  Do not put hex color values in tool configurations.
  The one exception is `wezterm/colors/tracer.toml`, which defines the [Tracer](https://github.com/y4m3/tracer-color) scheme itself.

## Machine-local overrides

chezmoi creates each file below once. After that, the machine owns it, and
chezmoi never overwrites it again.

| File | Overrides |
| --- | --- |
| `~/.bashrc.local` | bash |
| `~/.gitconfig.local` | git identity |
| `~/.config/wezterm/local.lua` | WezTerm (font, color scheme, WSL domain, key bindings) |
| `~/.config/tmux/tmux.local.conf` | tmux |
| `~/.config/nvim/lua/plugins/*.lua` | nvim — no template file; add files here, lazy.nvim imports the whole directory |

## Quick start

### Linux / WSL

1. Run this command:

   ```sh
   curl -fsLS https://raw.githubusercontent.com/y4m3/dotfiles/main/install.sh | sh
   ```

   One run installs everything: apt packages, Nix, Home Manager, Claude Code.

2. Start a new shell:

   ```sh
   exec bash
   ```

Some steps can fail. For example, sudo can ask for a password but not
receive one. If a step fails, correct the problem. Then run `chezmoi apply`
again.

### Windows

1. Run this command in PowerShell:

   ```powershell
   irm https://raw.githubusercontent.com/y4m3/dotfiles/main/install.ps1 | iex
   ```

## Manual steps

Do these steps one time on each new machine:

- Write your git email in `~/.gitconfig.local`.
- Start `nvim` one time to install the plugins.
  Then run `chezmoi add ~/.config/nvim/lazy-lock.json` and commit the file.
- Windows: install a font if you want one.
  Set it in `~/.config/wezterm/local.lua`.
- Windows: if OneDrive moves your `Documents` folder, make a link to the PowerShell profile.

## Maintenance

- To add a package: edit `home/.chezmoidata/packages.yaml`. Then run `chezmoi apply`.
- To update Nix packages: run `nix flake update` in `~/.config/nix`.
  Then run `chezmoi add ~/.config/nix/flake.lock`, run `chezmoi apply`, and commit `flake.lock`.
  Without the `chezmoi add` step, `chezmoi apply` reverts the updated lock file.
- To update nvim plugins: run `:Lazy update`.
  Then run `chezmoi add ~/.config/nvim/lazy-lock.json` and commit the file.
- To check the shell scripts: run `./lint`.

## Layout

```
install.sh / install.ps1     Bootstrap scripts
lint                         Lint script (shellcheck, shfmt, template sanity; also covers install.sh and itself)
home/
  .chezmoidata/              Tool list (single source of truth)
  .chezmoiscripts/           Install scripts (apt, Nix, Claude Code, win32yank, mo, winget)
  dot_bashrc, dot_bashrc.d/  Shell initialization
  dot_config/herdr/          Multiplexer config (primary; tmux is the fallback)
  dot_config/nix/            Nix flake and Home Manager (generated from packages.yaml)
  dot_config/nvim/           LazyVim (markdown, python, sql)
  dot_config/tmux/           Fallback multiplexer
  dot_config/wezterm/        Terminal emulator (Tracer colors, OS-boundary tabs)
```
