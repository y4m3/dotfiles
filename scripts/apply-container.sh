#!/usr/bin/env bash
set -euo pipefail

SRC=${1:-/workspace}
DEST=${2:-/root}

chezmoi init --source="$SRC" --destination="$DEST"
chezmoi apply --source="$SRC" --destination="$DEST" --force

# Execute run_once_* scripts since chezmoi may not run them automatically in non-interactive shells
# chezmoi deploys them to a temporary location and tracks state
# We need to explicitly run them in non-interactive environments like Docker
echo "==> Running chezmoi run_once scripts..."
for script in "$SRC"/home/run_once_[0-9]*.sh.tmpl; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script" .tmpl)
        echo "Executing: $script_name"
        # Remove .tmpl extension and run (no template vars in these scripts)
        if ! bash "$script"; then
            echo "Error: Failed to execute $script_name" >&2
            exit 1
        fi
    fi
done
echo "✓ All run_once scripts executed successfully"
