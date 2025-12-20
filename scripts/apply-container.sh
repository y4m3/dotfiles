#!/usr/bin/env bash
set -euo pipefail

SRC=${1:-/workspace}
DEST=${2:-/root}

chezmoi init --source="$SRC" --destination="$DEST"
chezmoi apply --source="$SRC" --destination="$DEST" --force

# Execute scripts deployed from run_once_* templates
# chezmoi strips the run_once_ prefix when deploying
# Pattern matches: 00-prerequisites.sh, 10-install-rust.sh, etc.
for script in "$DEST"/[0-9][0-9]-*.sh; do
	if [ -f "$script" ]; then
		echo "Running: $script"
		bash "$script"
	fi
done
