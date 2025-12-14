#!/usr/bin/env bash
set -euo pipefail

SRC=${1:-/workspace}
DEST=${2:-/root}

chezmoi init --source="$SRC" --destination="$DEST"
chezmoi apply --source="$SRC" --destination="$DEST" --force

# Note: run-once runner removed. Prefer using chezmoi-native `create_`
# templates (e.g. `home/create_.bashrc.local.tmpl`) for create-if-missing
# behaviour. If you need more complex per-destination initialization,
# add explicit scripts to your container pipeline instead of embedding
# them here.
