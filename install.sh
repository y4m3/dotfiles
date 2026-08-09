#!/bin/sh
# Bootstrap for Linux/WSL: install chezmoi if missing, then init+apply.
set -eu

CHEZMOI_BIN_DIR="${HOME}/.local/bin"
REPO="y4m3"

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "==> Installing chezmoi to ${CHEZMOI_BIN_DIR}"
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${CHEZMOI_BIN_DIR}"
  PATH="${CHEZMOI_BIN_DIR}:${PATH}"
fi

script_dir="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
if [ -f "${script_dir}/.chezmoiroot" ]; then
  # Running from a local clone
  exec chezmoi init --apply --source="${script_dir}"
fi

# Running via curl | sh
branch="${DOTFILES_BRANCH:-main}"
exec chezmoi init --apply --branch "${branch}" "${REPO}"
