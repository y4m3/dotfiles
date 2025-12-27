# shellcheck and shfmt

Concise notes focused on environment-specific behavior. See official docs for usage.

## Official Documentation

- shellcheck: https://github.com/koalaman/shellcheck
- shfmt: https://github.com/mvdan/sh

## Installation

Managed by `run_once_250-shell-shellcheck.sh.tmpl`:
- Installs `shellcheck` and `shfmt` to `~/.local/bin/`

## Environment-specific Integration

- Make targets:
  - `make lint` runs shellcheck across `*.sh`
  - `make format` runs shfmt across `home/` and `scripts/`
- CI and hooks are not enforced here; use project-specific configuration as needed.

 
