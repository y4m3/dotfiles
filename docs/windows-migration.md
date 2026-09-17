# Windows migration

## Existing machines

The source changes do not uninstall applications. `chezmoi apply` installs
the new suppliers, deploys configuration, and adds mise shims to user PATH.
It does not remove old runtimes, npm globals, GUI apps, or their settings.
It can change which executable a new shell resolves; review the diff first.

1. Record existing versions/paths (`Get-Command node,uv,nvim -All`,
   `npm.cmd list -g --depth=0`, `uv tool list`) and review `chezmoi diff`.
2. Apply the configuration when ready. mise installs before the uv tools;
   both scripts run after configuration deployment and fail on errors so
   a later apply retries. Linux/WSL package ownership remains unchanged.
3. Open a new PowerShell. Check `mise ls`, `mise doctor`, `Get-Command
   node,uv,tree-sitter -All`, then `./doctor.ps1`. Compare GUI-launched
   processes too: machine PATH entries can shadow user shims.
4. Check Neovim with `:Lazy restore`, restart, `:TSUpdate`,
   `:checkhealth nvim-treesitter`, `:LspInfo`, and real formatting of Lua,
   Markdown, TOML and Python files. Verify a parser can be built with gcc.
5. Only after those checks, decide whether to remove each old installation.
   Preserve existing packages until then. Never bulk-uninstall this list.

These winget IDs have moved to mise and may remain installed on an older PC:

```text
OpenJS.NodeJS.LTS
astral-sh.uv
Artempyanykh.Marksman
JohnnyMorganz.StyLua
LuaLS.lua-language-server
mvdan.shfmt
tamasfe.taplo
tree-sitter.tree-sitter-cli
koalaman.shellcheck
```

The old npm-global markdown-toc, markdownlint-cli2, and prettier also remain
until deliberately removed using the original npm installation. Record its
prefix before replacing Node. The old npm bootstrap script was removed;
these tools now use separate mise npm installations.

WezTerm's winget declaration was removed, but its chezmoi config remains.
An existing working WezTerm does not need to be uninstalled just to change
the update owner. Check scope/channel before running its official installer
over an existing copy. btop4win's declaration, shell alias and required
doctor check were removed; the installed app is left alone. Nix btop stays.

uv tools retain their existing environments. New installs request uv-managed
Python so deleting a mise Python later cannot invalidate them. If an existing
tool uses an interpreter you intend to remove, inspect `uv tool list` and
reinstall that individual tool with `uv tool install --reinstall
--managed-python <tool>` before removing the interpreter.

## Local GUI inventory

Keep `~/.local/setup/packages-local.yaml` outside chezmoi/git. It is an
inventory/checklist, not a winget installation manifest. All selected GUI
apps use official installers; company distribution takes precedence.
The inventory can record `name`, `officialUrl`, `install: official|company`,
`update: self|official|company`, and optional `wingetId`/`wingetPin`.
Do not put credentials or company download URLs in remote dotfiles.

If an `install-local.ps1` is added locally, its default job is to report
missing apps and their official links. It should not silently download/run
installers or switch an existing Store/enterprise installation to another
channel. A pin operation is separate and explicit.

Chrome/Firefox should follow the approved browser channel and updater.
VS Code, Zed, Obsidian, Heynote and Zen use their official distribution;
confirm updater behavior for the actual build installed. Obsidian also
needs occasional installer refreshes for its Electron runtime. Slack Store
and direct-download builds have different update owners; Zoom EXE and
enterprise MSI policies differ. Options+/Logi Tune should follow company
device-management policy. PowerToys has its own update check. KeePassXC,
SumatraPDF and AutoHotkey can be refreshed with official installers;
preserve the AutoHotkey major required by existing scripts.

For a self-updating app recognized by winget, a local blocking pin can keep
winget from also updating it, for example (only after checking the ID):

```powershell
winget pin add --id wez.wezterm --exact --source winget --blocking
```

Pins do not stop official installers/self-updaters. New apps can appear in
`winget upgrade --all` until pinned. Prefer the repository's allowlist update
script for routine CLI maintenance.

## References

- [winget upgrade](https://learn.microsoft.com/en-us/windows/package-manager/winget/upgrade)
  and [pins](https://learn.microsoft.com/en-us/windows/package-manager/winget/pinning)
- [mise Windows installation](https://mise.jdx.dev/installing-mise.html),
  [registry](https://mise.jdx.dev/registry.html),
  [npm backend](https://mise.jdx.dev/dev-tools/backends/npm.html),
  [shims](https://mise.jdx.dev/dev-tools/shims.html),
  [upgrade semantics](https://mise.jdx.dev/cli/upgrade.html)
- [uv installation/update](https://docs.astral.sh/uv/getting-started/installation/)
  and [tools](https://docs.astral.sh/uv/guides/tools/)
- [Pinned LazyVim treesitter spec](https://github.com/LazyVim/LazyVim/blob/c10948c50b18fae7f256433afdef09e432410480/lua/lazyvim/plugins/treesitter.lua)
- [Prettier project-local installation](https://prettier.io/docs/install)
- [WezTerm installer](https://wezterm.org/install/windows.html),
  [Obsidian updates](https://obsidian.md/help/updates),
  [Slack updates](https://slack.com/help/articles/360048367814-Update-the-Slack-desktop-app),
  [PowerToys](https://learn.microsoft.com/en-us/windows/powertoys/install)
