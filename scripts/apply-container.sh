#!/usr/bin/env bash
set -euo pipefail

SRC=${1:-/workspace}
DEST=${2:-/root}

# Initialize chezmoi configuration
# This generates ~/.config/chezmoi/chezmoi.toml from .chezmoi.toml.tmpl
chezmoi init --source="$SRC"

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

# Setup fnm (Fast Node Manager) if installed
FNM_PATH="$HOME/.local/share/fnm"
if [ -x "$FNM_PATH/fnm" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$("$FNM_PATH/fnm" env)"
fi

# Note: .chezmoiscripts/run_onchange_* scripts are automatically executed by chezmoi apply
# No manual script execution needed - chezmoi handles this natively
echo "✓ chezmoi apply completed (.chezmoiscripts/ executed automatically)"
