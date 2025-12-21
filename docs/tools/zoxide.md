# zoxide

Fast directory jumping tool. Used as an alternative to `cd`, intelligently guessing directories based on access frequency.

## Basic Usage

### Initial Setup

For first-time use, teach frequently used directories:

```bash
j add /home/user/projects
j add /var/log
j add ~/.config
```

### Jump Commands

After learning, jump with partial matches:

```bash
j proj      # Jump to /home/user/projects
j log       # Jump to /var/log
j conf      # Jump to ~/.config
```

### Query Verification

Check what path zoxide will guess:

```bash
zoxide query proj
zoxide query -l     # Display all learned paths
```

## Custom Configuration

### Environment Variables

- `_ZO_DATA_DIR`: Database storage location (default: `~/.local/share/zoxide`)
- `_ZO_ECHO`: Display jump destination (enabled in this dotfiles)
- `_ZO_EXCLUDE_DIRS`: Directories to exclude from learning (e.g., `/tmp/*`)

### Auto ls After cd

Set the following in `.bashrc.local` to automatically run `ls` after `cd`:

```bash
export ENABLE_CD_LS=1
```

This setting is implemented in `60-utils.sh` and wraps the normal `cd` command.

## Troubleshooting

### j Command Not Found

The `j` function is not defined in non-interactive shells. Use in interactive shells:

```bash
# Reload in login shell
exec bash -l

# Or load individually
source ~/.bashrc.d/60-utils.sh
```

### Database Corrupted

```bash
# Delete database and rebuild
rm -rf ~/.local/share/zoxide
j add /path/to/important/dir
```

## Implementation Details

This dotfiles implements as follows:

- `60-utils.sh`: Defines `j` wrapper function
  - `j add <dir>`: Explicitly learn directory
  - `j <query>`: Call `__zoxide_z` to jump
- Rust binary, requires Cargo installation
- Rust installed by `run_once_100-runtimes-rust.sh`
- zoxide installed by `run_once_210-shell-cargo-tools.sh`
