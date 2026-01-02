#!/usr/bin/env bash
set -euo pipefail

SRC=${1:-/workspace}
DEST=${2:-/root}

# Apply dotfiles configuration
# Clean up any stale lock files
if [ -d "$HOME/.config/chezmoi" ]; then
  if ! find "$HOME/.config/chezmoi" -name "*.lock" -type f -delete 2>&1; then
    echo "Warning: Some lock files could not be deleted" >&2
  fi
fi

# Apply configuration with retry logic
apply_success=0
for retry in {1..3}; do
  if chezmoi apply --source="$SRC" --destination="$DEST" --force 2>&1; then
    apply_success=1
    break
  else
    if [ "$retry" -lt 3 ]; then
      echo "Waiting for chezmoi lock to be released (attempt $retry/3)..." >&2
      sleep 2
    fi
  fi
done

if [ $apply_success -eq 0 ]; then
  echo "Error: Failed to apply chezmoi configuration after retries" >&2
  exit 1
fi

# Source bash profile to ensure PATH is set correctly
# This is critical for tools installed to ~/.local/bin or ~/.cargo/bin
if [ -f "$HOME/.bash_profile" ]; then
  source "$HOME/.bash_profile"
fi
# Also ensure common paths are in PATH (in case .bash_profile doesn't load .bashrc)
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:${PATH:-}"

# Execute run_once_* scripts that haven't been executed yet
echo "==> Checking and executing run_once scripts..."

for script in "$SRC"/home/run_once_[0-9]*.sh.tmpl; do
  if [ ! -f "$script" ]; then
    continue
  fi

  script_name=$(basename "$script" .tmpl)
  # Use script content hash as state key (chezmoi's approach)
  # This ensures scripts are re-executed if their content changes
  script_hash=$(chezmoi execute-template --source="$SRC" --destination="$DEST" < "$script" 2> /dev/null | sha256sum | cut -d' ' -f1)
  script_key="run_once_${script_hash}"

  # Check if script has already been executed
  if chezmoi state get --bucket=scriptState --key="$script_key" --source="$SRC" --destination="$DEST" > /dev/null 2>&1; then
    echo "  Skipping $script_name (already executed)"
    continue
  fi

  # Execute the script
  echo "  Executing $script_name..."
  if script_output=$(chezmoi execute-template --source="$SRC" --destination="$DEST" < "$script" 2>&1 | bash 2>&1); then
    echo "  ✓ $script_name completed successfully"
    # Record script execution in chezmoi state
    if chezmoi state set --bucket=scriptState --key="$script_key" --value="executed" --source="$SRC" --destination="$DEST" > /dev/null 2>&1; then
      : # State recorded successfully
    else
      echo "  Warning: Failed to record script execution state for $script_name" >&2
    fi
  else
    echo "  Error: Failed to execute $script_name" >&2
    echo "$script_output" >&2
    exit 1
  fi
done

echo "✓ All run_once scripts processed"
