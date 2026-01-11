# shellcheck and shfmt

Concise notes focused on environment-specific behavior. See official docs for usage.

## Official Documentation

- shellcheck: https://github.com/koalaman/shellcheck
- shfmt: https://github.com/mvdan/sh

## Installation

Managed by Nix Home Manager (`home/dot_config/nix/home.nix`).

## Environment-specific Integration

- Just targets:
  - `just lint` runs shellcheck across `*.sh`
  - `just format` runs shfmt across `home/`
- CI and hooks are not enforced here; use project-specific configuration as needed.
