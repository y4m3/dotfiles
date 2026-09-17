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
  Windows uses winget for shared shell/editor infrastructure, mise for
  runtimes and editor tools, uv for Python CLI tools, and PSGallery for PSFzf.
  WezTerm and other GUI apps use official installers (company distribution
  takes precedence). GUI installation manifests stay outside this repository.
- `flake.lock` and `lazy-lock.json` are in git.
  These lock Nix and plugin revisions, not every Windows package.
  Windows editor tools have explicit versions in `packages.mise`; Node
  follows the declared major, uv follows latest, and winget/uv tools update
  separately. Project dependencies belong in project configuration/lockfiles.
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

### Package ownership and updates

| Component | Before | Now | Update |
| --- | --- | --- | --- |
| Git, PowerShell, Neovim, shared CLI, C compiler | winget | winget | `./update-windows.ps1 -Apply` (editor/compiler opt-in below) |
| mise itself | absent | winget | same command |
| Node | winget | mise, selected major | `mise upgrade node` |
| uv itself | winget | mise | `mise upgrade uv`; do not use `uv self update` |
| Marksman, StyLua, LuaLS, Taplo, tree-sitter CLI, shfmt, ShellCheck | winget | mise, explicit versions | edit `packages.mise`, then `chezmoi apply` |
| markdown-toc, markdownlint-cli2, Prettier | global npm | mise npm backend, explicit versions | edit `packages.mise`, then `chezmoi apply` |
| ruff, ty, SQLFluff on Windows | uv tool | uv tool | `uv tool upgrade --all` |
| WezTerm | winget | official installer; chezmoi still supplies config | official release installer |
| btop4win | winget | no longer declared | no automatic removal of existing installation |
| Linux/WSL | Nix/Home Manager | unchanged | existing Nix workflow below |

mise supplies default tools for editing standalone files. A project's
`mise.toml`, `package.json` and lockfile, or `pyproject.toml` and `uv.lock`
own that project's versions. Prefer project-local formatters when configured.
No global Python is required just for uv tools: uv supplies their managed
Python. Add a mise Python version only when a Windows project needs it, and
avoid two managers owning the same interpreter. On Linux, Nix continues to
supply ruff/ty/SQLFluff; do not duplicate them with global uv tool installs.

`mise upgrade` updates floating declarations such as Node's major and uv's
latest; it does not bump exact editor-tool pins. Edit `packages.yaml` for
those pins. Do not edit the generated mise config or run `mise use -g` /
`mise upgrade --bump` against it without porting the change back to YAML:
the next apply would overwrite it. Install scripts ensure presence and
retry failures; they are not scheduled updaters.

Windows mise config is deployed to `~/.config/mise/config.toml`. With this
repo's XDG settings its data/shims live under `~/.local/share/mise`, unless
`MISE_DATA_DIR` overrides that location. The user PATH includes the shims;
the PowerShell profile also puts them before old machine PATH runtimes.
Start a new session after apply. For a GUI/automation process with an old
PATH, launch through `mise exec -- <command>` or restart its parent process.
Bootstrap invokes mise explicitly and does not depend on a loaded profile.

### Safe winget scope

All repository winget operations select `--source winget`. They do not
modify/remove msstore or bypass certificate verification.

```powershell
# Preview only packages declared by this repository; makes no installations.
.\update-windows.ps1
# Update that list, excluding Neovim and the parser compiler by default.
.\update-windows.ps1 -Apply
# Explicit editor/compiler maintenance, then check plugins/parser builds.
.\update-windows.ps1 -Apply -IncludeEditorToolchain
```

`winget upgrade --all --source winget` is broader: it may update recognized
apps installed by official installers too. Removing an ID from YAML does
not uninstall it, exclude it from winget, or remove its old PATH entries.
Preview with `winget upgrade --source winget` before a machine-wide update.
Use local pins for apps owned by self-updaters/company IT and for editor or
compiler versions you want to hold. Ordinary pins exclude bulk updates;
blocking pins also exclude explicit winget upgrades. Neither stops the
application's own updater. This repo does not silently set or reset pins.
Do not routinely use `--force`, `--include-pinned`, or `--include-unknown`.

Native parser installation still needs a C compiler, tar, curl, and a
compatible tree-sitter CLI (the native release, not the npm package).
WinLibs is retained for that job. The nvim-treesitter lock entry matches
the Neovim 0.11 compatibility commit selected by the pinned LazyVim spec;
do not independently advance it to main HEAD. Review the Neovim, LazyVim,
tree-sitter CLI and parser combination together, run `:TSUpdate` after a
plugin change, and check `:checkhealth nvim-treesitter` and `:LspInfo`.

See [Windows migration](docs/windows-migration.md) for the existing-machine
transition, the local GUI inventory design, and upstream references.

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

1. Install [WezTerm](https://wezterm.org/install/windows.html) with its official
   installer if you want it on this machine. Other GUI apps are also manual
   official-installer/company-managed choices, outside bootstrap.

2. Run this command in PowerShell:

   ```powershell
   irm https://raw.githubusercontent.com/y4m3/dotfiles/main/install.ps1 | iex
   ```

3. Start a new PowerShell session.
   The install sets environment variables and PATH entries. Only a new session picks them up.

## Manual steps

Do these steps one time on each new machine:

- Write your git email in `~/.gitconfig.local`.
- Start `nvim` one time to install the plugins.
  Then run `chezmoi add ~/.config/nvim/lazy-lock.json` and commit the file.
- Windows: install a font if you want one.
  Set it in `~/.config/wezterm/local.lua`.
- Windows: run `.\doctor.ps1` to confirm the environment. Linux: run `./doctor.sh`.

## Maintenance

- To add a package: edit the matching group (`nix`, `winget`, `mise`, `uv`, `psgallery`, or `apt`) in `home/.chezmoidata/packages.yaml`. Then run `chezmoi apply`.
- To update Nix packages: run `nix flake update` in `~/.config/nix`.
  Then run `chezmoi add ~/.config/nix/flake.lock`, run `chezmoi apply`, and commit `flake.lock`.
  Without the `chezmoi add` step, `chezmoi apply` reverts the updated lock file.
- To update nvim plugins: run `:Lazy update`.
  Then run `chezmoi add ~/.config/nvim/lazy-lock.json` and commit the file.
- To check the shell scripts: run `./lint`.
- To validate Windows templates and winget failure handling without installing
  anything: run `pwsh -NoProfile -File tests/windows-bootstrap.ps1`.
- Windows: run `.\doctor.ps1` to check the environment. It compares the declared packages against the machine, and it reports a tool that comes from a package manager this repo does not declare, or from a second build of a declared winget package.
- Linux: run `./doctor.sh`, the same check for the other side. It reports a declared Nix package that is missing or shadowed by a copy earlier on PATH, a PATH entry that is duplicated or gone, and a git identity still unset.

## Layout

```
install.sh / install.ps1     Bootstrap scripts
lint                         Lint script (shellcheck, shfmt, template sanity; also covers install.sh and itself)
doctor.ps1                   Windows environment health check (read-only)
doctor.sh                    Linux environment health check (read-only)
update-windows.ps1            Preview/update only declared Windows packages
home/
  .chezmoidata/              Tool list (single source of truth)
  .chezmoiscripts/           Install scripts (apt, Nix, Claude Code, win32yank, mo, winget, Windows XDG variables, mise, uv, PSGallery, pwsh profile loader)
  dot_config/mise/           Windows runtime/editor tool versions (from YAML)
  dot_bashrc, dot_bashrc.d/  Shell initialization
  dot_config/herdr/          Multiplexer config (primary; tmux is the fallback)
  dot_config/nix/            Nix flake and Home Manager (generated from packages.yaml)
  dot_config/nvim/           LazyVim (markdown, python, sql)
  dot_config/powershell/     pwsh profile body ($PROFILE holds a loader for it)
  dot_config/tmux/           Fallback multiplexer
  dot_config/wezterm/        Terminal emulator (Tracer colors, OS-boundary tabs)
```
