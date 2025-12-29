# GitHub Tools

Development tools for GitHub integration.

## gh (GitHub CLI)

Official GitHub command-line tool. Execute PR, Issue, and repository operations from the terminal.

**Official Documentation**: https://cli.github.com/manual/

### Installation Method (Environment-specific)

- Managed by `run_once_300-devtools-gh.sh.tmpl`
- Uses the official APT repository for updates and security

## ghq (Repository Manager)

Tool for unified Git repository management. Clones into structures like `~/ghq/github.com/owner/repo`.

**Official Documentation**: https://github.com/x-motemen/ghq

### Configuration (Environment-specific)

- `ghq.root` is set via global git config to `~/repos` for a predictable local path structure.

### Integration with fzf

Combining ghq with fzf enables fast repository search and navigation:

```bash
# Interactively select repository and navigate
cd $(ghq list -p | fzf)

# Example alias (add to .bashrc.local)
alias repo='cd $(ghq list -p | fzf)'
```

### Installation Method

This dotfiles installs via Go's `go install`:

```bash
# Automatically executed in run_once_310-devtools-ghq.sh
go install github.com/x-motemen/ghq@latest
```

**Prerequisites**: Requires `golang-go` package (installed by `run_once_000-prerequisites.sh`)

**Policy**: Since ghq is a Go tool, we use `go install`. This is the most reliable method as there's no official package and binary distribution is limited.

### Custom Configuration

Configurable in `~/.gitconfig`:

```ini
[ghq]
    root = ~/ghq           # Repository root directory
    # root = ~/src         # Multiple roots can also be configured
```

## Troubleshooting

### gh Not Found

Check if APT repository is correctly added:

```bash
apt policy gh
# If reinstallation is needed
bash home/run_once_300-devtools-gh.sh.tmpl
```

### ghq Not Found

Check if Go is installed:

```bash
command -v go && go version

# If Go is missing
bash home/run_once_000-prerequisites.sh.tmpl

# Reinstall ghq
bash home/run_once_310-devtools-ghq.sh.tmpl
```

### GOPATH Configuration

Binaries installed with `go install` are placed in `~/go/bin`. Check if it's in PATH:

```bash
echo "$PATH" | grep go/bin

# If not included, add to .bashrc.local
export PATH="$HOME/go/bin:$PATH"
```
