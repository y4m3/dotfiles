# uv

Concise notes focused on environment-specific behavior. See official docs for usage.

## Official Documentation

https://github.com/astral-sh/uv

## Installation

Managed by Nix Home Manager (`home/dot_config/nix/home.nix`).

## Environment-specific Configuration

- Recommended direnv integration for auto-venv:
	- Add `layout python_uv` to project `.envrc`, then `direnv allow`.
- Python versions and venvs are managed per-project; no global Python enforced.
