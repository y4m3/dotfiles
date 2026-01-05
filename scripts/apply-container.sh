#!/usr/bin/env bash
set -euo pipefail

SRC=${1:-/workspace}
DEST=${2:-/root}

# Verify and reinstall missing apt packages
# apt packages install to /usr/bin which doesn't persist in Docker volumes
# This function checks if expected packages are installed and reinstalls if missing
verify_apt_packages() {
    local config_file="$SRC/scripts/apt-packages.json"
    if [ ! -f "$config_file" ]; then
        return 0
    fi

    # Check if jq is available
    if ! command -v jq >/dev/null 2>&1; then
        echo "Warning: jq not available, skipping apt package verification" >&2
        return 0
    fi

    local missing_count=0
    local packages
    packages=$(jq -r '.packages[] | "\(.command)|\(.script)|\(.name)"' "$config_file")

    while IFS='|' read -r cmd script name; do
        [ -z "$cmd" ] && continue
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "==> Reinstalling missing apt package: $name"
            local script_path="$SRC/$script"
            if [ -f "$script_path" ]; then
                # Use chezmoi execute-template to properly process template variables
                # This respects conditional guards and template variables
                local processed_script
                processed_script=$(chezmoi execute-template < "$script_path" 2>/dev/null)
                if [ -n "$processed_script" ]; then
                    if bash <(echo "$processed_script"); then
                        echo "==> $name reinstalled successfully"
                    else
                        echo "Warning: Failed to reinstall $name" >&2
                        missing_count=$((missing_count + 1))
                    fi
                else
                    echo "Warning: Template condition not met for $name (skipping)" >&2
                fi
            else
                echo "Warning: Script not found: $script_path" >&2
                missing_count=$((missing_count + 1))
            fi
        fi
    done <<< "$packages"

    return $missing_count
}

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

# Verify apt packages (may need reinstall in Docker where /usr/bin doesn't persist)
verify_apt_packages || echo "Warning: Some apt packages could not be verified" >&2
