# uv

Concise notes focused on environment-specific behavior. See official docs for usage.

## Official Documentation

https://github.com/astral-sh/uv

## Installation

Managed by `run_once_120-runtimes-python-uv.sh.tmpl`:
- Installed to `~/.cargo/bin/uv`
- PATH integration via `home/dot_bashrc.d/200-runtimes.sh`

## Environment-specific Configuration

- Recommended direnv integration for auto-venv:
	- Add `layout python_uv` to project `.envrc`, then `direnv allow`.
- Python versions and venvs are managed per-project; no global Python enforced.
