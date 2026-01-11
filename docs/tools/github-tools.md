# GitHub Tools

Development tools for GitHub integration.

## gh (GitHub CLI)

Official GitHub command-line tool. Execute PR, Issue, and repository operations from the terminal.

**Official Documentation**: https://cli.github.com/manual/

### Installation

Managed by Nix Home Manager (`home/dot_config/nix/home.nix`).

### Authentication

After installing `gh`, authenticate with GitHub:

```bash
gh auth login
```

Verify: `gh auth status`

### Security Best Practices

1. **File Permissions**: Automatically set strict permissions (`~/.config/gh`: 700, `hosts.yml`: 600) via `75-security-permissions.sh`
2. **Fine-grained PATs**: Prefer fine-grained Personal Access Tokens over classic tokens
3. **Token Rotation**: Regularly rotate tokens: `gh auth refresh`

Verify permissions:
```bash
ls -ld ~/.config/gh        # Should show drwx------
ls -l ~/.config/gh/hosts.yml  # Should show -rw-------
```

## ghq (Repository Manager)

Tool for unified Git repository management. Clones into structures like `~/ghq/github.com/owner/repo`.

**Official Documentation**: https://github.com/x-motemen/ghq

### Installation

Managed by Nix Home Manager (`home/dot_config/nix/home.nix`).

### Configuration

Configure in `~/.gitconfig`:

```ini
[ghq]
    root = ~/ghq
```

### Integration with fzf

```bash
# Interactively select repository and navigate
cd $(ghq list -p | fzf)

# Example alias (add to .bashrc.local)
alias repo='cd $(ghq list -p | fzf)'
```

## Troubleshooting

- **gh not found**: Ensure Nix profile is in PATH: `echo $PATH | grep nix`
- **ghq not found**: Ensure Nix profile is in PATH: `echo $PATH | grep nix`
