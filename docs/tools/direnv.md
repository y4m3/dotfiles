# direnv

Load and unload environment variables depending on the current directory.

## Official Documentation

https://direnv.net/

## Installation

Managed by `run_once_240-shell-direnv.sh.tmpl`:
- Downloads latest release from GitHub
- Installs to `~/.local/bin/direnv`
- Shell hook added in `~/.bashrc.d/50-direnv.sh`

## Configuration

### Shell Integration

Automatically loaded via `~/.bashrc.d/50-direnv.sh`:
```bash
eval "$(direnv hook bash)"
```

## Team Policy

- `.envrc` is per-project and versioned for the team.
- Use only direnv stdlib and widely available tool commands (e.g., `uv`).

## Usage

1. Create `.envrc` in the project root.
2. Add portable patterns (see examples below).
3. Run `direnv allow` to approve.

## Examples

See `docs/templates/envrc-examples.md` for portable snippets.

### Portable Python (uv preferred)
```sh
if command -v uv >/dev/null 2>&1; then
  [[ -d .venv ]] || uv venv
  export VIRTUAL_ENV="$PWD/.venv"
  PATH_add "$VIRTUAL_ENV/bin"
  [[ -f pyproject.toml ]] && uv sync --frozen || true
  export PYTHONNOUSERSITE=1
else
  layout python
fi
```

### Node local binaries
```sh
[[ -d node_modules/.bin ]] && PATH_add node_modules/.bin
```

### Load .env and watch changes
```sh
dotenv_if_exists .env
watch_file .env
```

## Security

- `.envrc` must be explicitly allowed with `direnv allow`.
- Changes to `.envrc` require re-approval.
- Keep secrets out of VCS.
