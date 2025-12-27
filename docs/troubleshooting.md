# Troubleshooting

Common issues and solutions for this dotfiles.

## Quick re-apply on host

```bash
# Initial apply (host)
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME

# Update later
chezmoi update
```

## General Issues

### Re-running run_once scripts

ChezMoi tracks executed run_once scripts. To re-run:

- **Clean chezmoi state (host):**
	```bash
	rm -rf ~/.local/share/chezmoi/run_once_*
	chezmoi apply
	```

- **Docker reset (optional for validation):**
	```bash
	make clean-state
	make build
	make test
	```

- **Run a specific script manually:**
	```bash
	bash home/run_once_000-prerequisites.sh.tmpl
	bash home/run_once_240-shell-direnv.sh.tmpl
	```

### Added Directory Not Reflected in PATH

**Symptoms**: Added PATH in `.bashrc.local` but not shown in `echo $PATH`.

**Causes**: 
- bashrc not yet loaded
- Running in non-login shell

**Solutions**:

```bash
# Restart in login shell
exec bash -l

# Or reload .bashrc
source ~/.bashrc

# Verify PATH
echo "$PATH" | tr : '\n'
```

### .bashrc.local Not Taking Effect

**Symptoms**: Added configuration to `.bashrc.local` but not working.

**Causes**: 
- File doesn't exist
- Loading error present

**Solutions**:

```bash
# Check file existence
ls -la ~/.bashrc.local

# Check for syntax errors
bash -n ~/.bashrc.local

# Load manually to check for errors
source ~/.bashrc.local

# If errors appear, fix and reload
exec bash -l
```

## Tool-specific Issues

### zoxide/j Command Not Found

**Symptoms**: `bash: j: command not found`

**Causes**: 
- Running in non-interactive shell
- zoxide not installed
- `~/.cargo/bin` not in PATH

**Solutions**:

```bash
# 1. Check if running in interactive shell
[[ $- == *i* ]] && echo "Interactive shell" || echo "Non-interactive shell"

# 2. Check if zoxide is installed
command -v zoxide

# 3. Check PATH
echo "$PATH" | grep cargo

# 4. Restart in login shell
exec bash -l

# 5. If still not working, reinstall
bash home/run_once_100-runtimes-rust.sh.tmpl
bash home/run_once_210-shell-cargo-tools.sh.tmpl
```

### Cargo Tools Not Found

**Symptoms**: `bat`, `eza`, `fd`, `rg` etc. not found

**Cause**: `~/.cargo/bin` not in PATH

**Solutions**:

```bash
# Check PATH
echo "$PATH" | tr : '\n' | grep cargo

# If .cargo/bin is missing, add it
export PATH="$HOME/.cargo/bin:$PATH"

# To persist, add to .bashrc.local
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc.local

# Restart in login shell
exec bash -l
```

### gh Not Found

**Symptoms**: `bash: gh: command not found`

**Causes**: 
- gh not installed
- APT repository not correctly added

**Solutions**:

```bash
# 1. Check installation status via script
bash home/run_once_300-devtools-gh.sh.tmpl --check

# 2. Reinstall using managed script
bash home/run_once_300-devtools-gh.sh.tmpl

# 3. If still not working, re-run prerequisites
bash home/run_once_000-prerequisites.sh.tmpl
```

### ghq Not Found

**Symptoms**: `bash: ghq: command not found`

**Causes**: 
- Go not installed
- `~/go/bin` not in PATH

**Solutions**:

```bash
# 1. Check Go
command -v go && go version

# 2. If Go is missing, run prerequisites
bash home/run_once_000-prerequisites.sh.tmpl

# 3. Install ghq
bash home/run_once_310-devtools-ghq.sh.tmpl

# 4. Check PATH
echo "$PATH" | grep go/bin

# 5. If needed, add to .bashrc.local
echo 'export PATH="$HOME/go/bin:$PATH"' >> ~/.bashrc.local
exec bash -l
```

### fzf Key Bindings Not Working

**Symptoms**: `Ctrl+R`, `Ctrl+T`, `Alt+C` perform normal shell operations

**Cause**: `.fzf.bash` not loaded

**Solutions**:

```bash
# 1. Check if fzf is installed
command -v fzf

# 2. Check if .fzf.bash exists
ls -la ~/.fzf.bash

# 3. Load manually
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# 4. Verify .bashrc loads it
grep 'fzf.bash' ~/.bashrc

# 5. Restart in login shell
exec bash -l
```

## Error Message Specific

### `command not found: grep`

**Symptoms**: Running `grep -E` in script produces `command not found: grep` error

**Cause**: `alias grep='rg'` is set, and `grep -E` is interpreted as `rg -E`

**Solutions**:

```bash
# Use command in scripts
command grep -E 'pattern' file.txt

# Temporarily disable alias
\grep -E 'pattern' file.txt

# Completely remove with unalias (not recommended)
unalias grep
```

### `DEBIAN_FRONTEND: command not found`

**Symptoms**: This error appears when running script

**Cause**: Environment variable setting mistake (missing `export`)

**Solutions**:

```bash
# Wrong
DEBIAN_FRONTEND=noninteractive
apt-get install -y package

# Correct (same line)
DEBIAN_FRONTEND=noninteractive apt-get install -y package

# Correct (export)
export DEBIAN_FRONTEND=noninteractive
apt-get install -y package
```

### `fatal: not under version control`

**Symptoms**: `git mv` fails

**Cause**: File not under Git control

**Solutions**:

```bash
# Use regular mv
mv source destination

# Or add to git first
git add source
git mv source destination
```

## Test Issues

### make test fails

1. Identify the failing test:
```bash
make test
```
2. Run a specific test (inside container or host):
```bash
bash tests/<name>-test.sh
```
3. Manual verification shell:
```bash
make dev
```

### Reset test environment (Docker)

```bash
make clean-state
make build
make test
```

## Debugging Techniques

### Verify bashrc Load Order

```bash
# Add debug output to .bashrc
PS4='+ ${BASH_SOURCE}:${LINENO}: '
set -x
source ~/.bashrc
set +x
```

### Dump Environment Variables

```bash
# Display all environment variables
env | sort

# Display PATH clearly
echo "$PATH" | tr : '\n' | nl

# Search for specific variable
env | grep -i cargo
```

### Check Command Identity

```bash
# Check command type (alias/function/binary)
type grep
type j
type ls

# Display alias
alias grep
alias ls

# Display actual binary path
which -a grep
command -v grep
```

### Trace Script Execution

```bash
# Execute script in debug mode
bash -x home/run_once_000-prerequisites.sh.tmpl

# Trace only a portion
set -x
source ~/.bashrc.d/60-utils.sh
set +x
```

## Frequently Asked Questions

### Q: What is the execution order of run_once scripts?

A: Executed in filename number order (lexicographic order). `000` → `100` → `110` → `200` → ... → `310`

### Q: What's the difference between .bashrc and .bash_profile?

A: 
- `.bash_profile`: Loaded once in login shells
- `.bashrc`: Loaded in all interactive shells
- This dotfiles loads `.bashrc` from `.bash_profile`

### Q: Changes not reflected after chezmoi apply

A: Files starting with `create_` don't overwrite existing files. To reflect changes:

```bash
# Delete file then apply
rm ~/.bashrc.local
chezmoi apply

# Or check chezmoi managed files
chezmoi managed
```

### Q: Persist data in Docker container

A: `make dev` and `make test-shell` use persistent volumes:

- `dotfiles-state`: chezmoi state
- `cargo-data`: Cargo cache
- `rustup-data`: Rustup data

These are retained until deleted with `make clean-state`.

## Support

If issues aren't resolved:

1. Review this troubleshooting guide
2. Check design principles in [`docs/configuration.md`](./configuration.md)
3. Refer to detailed tool documentation (`docs/tools/*.md`)
4. Report in GitHub Issues (if applicable)
