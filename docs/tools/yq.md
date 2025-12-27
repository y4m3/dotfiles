# yq

Concise notes focused on environment-specific behavior. See official docs for usage.

## Official Documentation

https://github.com/mikefarah/yq

## Installation

Managed by `run_once_275-utils-yq.sh.tmpl`:
- Installs binary to `~/.local/bin/yq`
- Adds Bash completion to `~/.bash_completion.d/yq`

## Environment-specific Notes

- Used by repository tests in `tests/yq-test.sh`.
- No global configuration beyond completion; use per-command options as needed.
