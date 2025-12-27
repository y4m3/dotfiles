# zoxide

Concise notes focused on environment-specific configuration. Refer to official docs for general usage.

## Official Documentation

https://github.com/ajeetdsouza/zoxide

## Environment-specific Configuration

- Provides `j` command instead of `z` (defined in shell initialization)
- Optional auto `ls` enabled via `ENABLE_CD_LS=1` in `.bashrc.local`
- Exclusion paths and display behavior controlled by environment variables (e.g., `_ZO_EXCLUDE_DIRS`, `_ZO_ECHO`)

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
