# Git Tools

## delta

Syntax-highlighting pager for git diff with side-by-side view.

- **Docs**: https://github.com/dandavison/delta

**Configuration** (applied via dotfiles):

- `core.pager = delta`
- `interactive.diffFilter = delta --color-only`
- `delta.features = tokyo-night`
- `delta.navigate = true`, `delta.side-by-side = true`, `delta.line-numbers = true`

**Navigation in side-by-side mode:**

```bash
# When viewing diffs:
n       # Jump to next file
N       # Jump to previous file
q       # Quit
/       # Search (uses less)
```

The `navigate = true` setting enables `n`/`N` to jump between files in multi-file diffs.

---

## lazygit

Terminal UI for git operations. Stage, commit, push, manage branches, and resolve conflicts visually.

- **Docs**: https://github.com/jesseduffield/lazygit
- **Config**: `home/dot_config/lazygit/create_config.yml.tmpl`

**Environment-specific settings:**

- Mouse events enabled for click navigation
- Uses `$EDITOR`/`$VISUAL` for editing (integrates with Neovim)
- Other settings use defaults

**Key bindings:**

```bash
# Panels: 1-5 switch panels, Tab/Shift-Tab cycle
# Files: space (stage/unstage), a (stage all), c (commit)
# Branches: space (checkout), n (new branch), M (merge)
# Commits: r (reword), s (squash), f (fixup)
# General: ? (help), x (menu), q (quit)
```

**Workflow tip**: Use `lazygit` for interactive rebase and complex staging instead of command-line git.

---

## gh (GitHub CLI)

- **Docs**: https://cli.github.com/manual/
- **Auth**: `gh auth login` (verify: `gh auth status`)

**Security Best Practices**:

1. **File Permissions**: Strict permissions (`~/.config/gh`: 700, `hosts.yml`: 600) set via `040-security-permissions.sh`
2. **Fine-grained PATs**: Prefer fine-grained Personal Access Tokens over classic tokens
3. **Token Rotation**: Regularly rotate: `gh auth refresh`

---

## ghq

Repository management with structured paths (`~/repos/github.com/owner/repo`).

- **Docs**: https://github.com/x-motemen/ghq
- **Config**: `[ghq] root = ~/repos` in `~/.gitconfig`

**Basic usage:**

```bash
ghq get github.com/owner/repo  # Clone to ~/repos/github.com/owner/repo
ghq list                       # List all repositories (relative paths)
ghq list -p                    # List all repositories (absolute paths)
ghq root                       # Show root directory
```

**fzf integration:**

```bash
# Interactively select and navigate to repository
cd $(ghq list -p | fzf)

# Add to ~/.bashrc.local as alias
alias repo='cd $(ghq list -p | fzf --preview "ls -la {}")'
```

This environment uses `~/repos` as root (via `$GHQ_ROOT`). The `dev` command provides interactive navigation.

---

## Troubleshooting

- **Tool not found**: Ensure Nix profile is in PATH: `echo $PATH | grep nix`
