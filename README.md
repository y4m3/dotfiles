# Dotfiles

These dotfiles configure an agent-first development environment.
The primary platform is Ubuntu on WSL2.
Windows is a full second workstation.

Managed with [chezmoi](https://www.chezmoi.io/) and [Nix Home Manager](https://nix-community.github.io/home-manager/).

## Design rules

- The terminal is a cockpit for AI agents ([herdr](https://herdr.dev/), Claude Code).
  A tool gets a place only if it helps you drive agents, examine their output, or make changes by hand.
- One file lists all tools: `home/.chezmoidata/packages.yaml`.
  To add a tool, add one line to this file.
- Nix supplies Linux.
  winget is the main supplier on Windows.
  npm, uv, and PSGallery supply the tools that winget does not carry.
- `flake.lock` and `lazy-lock.json` are in git.
  Versions change only when you commit a change.
- herdr is the terminal multiplexer. Its config lives in `~/.config/herdr/config.toml`.
  tmux is the fallback.
- Colors come from the terminal ANSI palette (`bat`, `delta`, `herdr`, tmux).
  Do not put hex color values in tool configurations.
  The one exception is `wezterm/colors/tracer.toml`, which defines the [Tracer](https://github.com/y4m3/tracer-color) scheme itself.

## Windows layer

An install script sets the four XDG base directory variables. nvim then reads its config from `~/.config/nvim`, the same path as Linux.
Windows runs the same nvim toolchain as Linux: the editor, a C compiler for treesitter parser builds, the tree-sitter CLI, the LSP servers, and the formatters. Mason stays disabled.
git uses nvim and delta on both platforms.
The PowerShell profile gives the same shell behavior as bash: the same two-line prompt, the same aliases (`ls`, `ll`, `la`, `lt` from eza, `cat` from bat), `j` for zoxide, `dev` to jump to a ghq repository, and fzf on Ctrl+r and Ctrl+t.
It installs in two parts. The body sits at `~/.config/powershell/profile.ps1`, where OneDrive folder redirection cannot move it, and `$PROFILE` holds a loader that dot-sources it. Change the body with `chezmoi edit ~/.config/powershell/profile.ps1`, never the deployed copy, which the next apply overwrites; machine-local settings go in `~/.config/powershell/profile.local.ps1`, which the body reads last. A profile already at `$PROFILE` is kept beside it as `.pre-chezmoi.bak`, and the loader does not read it: copy anything you still want into `profile.local.ps1`.
Nix does not run on Windows, so tool versions can differ from the Linux versions.

## Machine-local overrides

chezmoi creates each file below once. After that, the machine owns it, and
chezmoi never overwrites it again.

| File | Overrides |
| --- | --- |
| `~/.bashrc.env.local` | bash environment — exports and PATH only, read before the interactive guard so scripts, ssh commands, and agents see it too |
| `~/.bashrc.local` | bash — aliases, functions, and anything else interactive-only |
| `~/.gitconfig.local` | git identity |
| `~/.config/wezterm/local.lua` | WezTerm (font, color scheme, WSL domain, key bindings) |
| `~/.config/tmux/tmux.local.conf` | tmux |
| `~/.config/powershell/profile.local.ps1` | the pwsh profile — no template file; the profile dot-sources it when it is there |
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

2. Start a new PowerShell session.
   The install sets environment variables and PATH entries. Only a new session picks them up.

## Manual steps

Do these steps one time on each new machine:

- Write your git email in `~/.gitconfig.local`.
- Start `nvim` one time to install the plugins.
  Then run `chezmoi add ~/.config/nvim/lazy-lock.json` and commit the file.
- Windows: install a font if you want one.
  Set it in `~/.config/wezterm/local.lua`.
- Windows: run `.\doctor.ps1` to confirm the environment.

## Maintenance

- To add a package: add one line to the matching group (`nix`, `winget`, `npm`, `uv`, `psgallery`, or `apt`) in `home/.chezmoidata/packages.yaml`. Then run `chezmoi apply`.
- To update Nix packages: run `nix flake update` in `~/.config/nix`.
  Then run `chezmoi add ~/.config/nix/flake.lock`, run `chezmoi apply`, and commit `flake.lock`.
  Without the `chezmoi add` step, `chezmoi apply` reverts the updated lock file.
- To update nvim plugins: run `:Lazy update`.
  Then run `chezmoi add ~/.config/nvim/lazy-lock.json` and commit the file.
- To check the shell scripts: run `./lint`.
- Windows: run `.\doctor.ps1` to check the environment. It compares the declared packages against the machine, and it reports a tool that comes from a package manager this repo does not declare.

## Layout

```
install.sh / install.ps1     Bootstrap scripts
lint                         Lint script (shellcheck, shfmt, template sanity; also covers install.sh and itself)
doctor.ps1                   Windows environment health check (read-only)
home/
  .chezmoidata/              Tool list (single source of truth)
  .chezmoiscripts/           Install scripts (apt, Nix, Claude Code, win32yank, mo, winget, Windows XDG variables, npm, uv, PSGallery, pwsh profile loader)
  dot_bashrc, dot_bashrc.d/  Shell initialization
  dot_config/herdr/          Multiplexer config (primary; tmux is the fallback)
  dot_config/nix/            Nix flake and Home Manager (generated from packages.yaml)
  dot_config/nvim/           LazyVim (markdown, python, sql)
  dot_config/powershell/     pwsh profile body ($PROFILE holds a loader for it)
  dot_config/tmux/           Fallback multiplexer
  dot_config/wezterm/        Terminal emulator (Tracer colors, OS-boundary tabs)
```
