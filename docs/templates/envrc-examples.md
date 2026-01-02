# direnv .envrc examples (team‑portable)

## Basic PATH extension
```sh
PATH_add bin
```

## Load .env automatically (if present)
```sh
# Load environment variables from .env and reload on changes
dotenv_if_exists .env
watch_file .env
```

## Python: prefer uv, fallback to built‑in
```sh
# Team‑portable Python environment activation
# Uses uv if available; otherwise falls back to direnv's layout python
if command -v uv >/dev/null 2>&1; then
  # Create venv if missing
  if [[ ! -d .venv ]]; then
    uv venv >/dev/null 2>&1 || exit 1
  fi

  # Activate venv
  export VIRTUAL_ENV="$PWD/.venv"
  PATH_add "$VIRTUAL_ENV/bin"

  # Optional: sync dependencies when pyproject is present
  # Note: If sync fails, you may want to handle the error explicitly
  if [[ -f pyproject.toml ]]; then
    # Keep direnv load non-fatal even if dependency sync fails.
    uv sync --frozen || { echo "Warning: uv sync failed" >&2; true; }
  fi

  # Avoid usersite interference
  export PYTHONNOUSERSITE=1
else
  # Standard Python venv managed by direnv
  layout python
fi
```

## Python: src/ layout helper
```sh
# If your project uses a src/ layout for imports
export PYTHONPATH="$PWD/src:$PYTHONPATH"
```

## Node: prefer local binaries
```sh
# Ensure project-local tools (e.g., eslint, jest) are available
if [[ -d node_modules/.bin ]]; then
  PATH_add node_modules/.bin
fi
```

## Secrets via environment (sample)
```sh
export AWS_PROFILE=work
export DATABASE_URL="postgres://user:pass@host/db"
```

Notes:
- Run `direnv allow` after creating or updating .envrc
- Keep secrets out of VCS; prefer vault/secret manager when possible
