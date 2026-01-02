# zoxide

Concise notes focused on environment-specific configuration. Refer to official docs for general usage.

## Official Documentation

https://github.com/ajeetdsouza/zoxide

## Environment-specific Configuration

- Provides `j` command instead of `z` (defined in shell initialization)
- Optional auto `ls` enabled via `ENABLE_CD_LS=1` in `.bashrc.local`
- Exclusion paths and display behavior controlled by environment variables (e.g., `_ZO_EXCLUDE_DIRS`, `_ZO_ECHO`)

## Troubleshooting

- **j command not found**: Use in interactive shells. Reload: `exec bash -l` or `source ~/.bashrc.d/299-zoxide.sh`
