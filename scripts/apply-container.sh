#!/usr/bin/env bash
set -euo pipefail

SRC=${1:-/workspace}
DEST=${2:-/root}

# Apply dotfiles configuration
# Clean up any stale lock files
if [ -d "$HOME/.config/chezmoi" ]; then
  if ! lock_delete_err=$(find "$HOME/.config/chezmoi" -name "*.lock" -type f -delete 2>&1); then
    if [ -n "$lock_delete_err" ]; then
      echo "Warning: Some lock files could not be deleted:" >&2
      printf '%s\n' "$lock_delete_err" >&2
    else
      echo "Warning: Some lock files could not be deleted" >&2
    fi
  fi
fi

# Apply configuration with retry logic
apply_success=0
apply_errors=()
for retry in {1..3}; do
  if apply_output=$(chezmoi apply --source="$SRC" --destination="$DEST" --force 2>&1); then
    apply_success=1
    break
  else
    apply_errors+=("Attempt $retry/3: $apply_output")
    if [ "$retry" -lt 3 ]; then
      echo "Waiting for chezmoi lock to be released (attempt $retry/3)..." >&2
      sleep 2
    fi
  fi
done

if [ $apply_success -eq 0 ]; then
  echo "Error: Failed to apply chezmoi configuration after retries" >&2
  for error in "${apply_errors[@]}"; do
    echo "  $error" >&2
  done
  exit 1
fi

# Source bash profile to ensure PATH is set correctly
if [ -f "$HOME/.bash_profile" ]; then
  source "$HOME/.bash_profile"
fi

# Load cargo environment to ensure cargo/rustup are in PATH
# This is critical for checking if Rust/Cargo tools are installed
if [ -f "$HOME/.cargo/env" ]; then
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
fi

# Source .bashrc to ensure PATH includes ~/.local/bin and ~/.cargo/bin
# This is needed for tool existence checks
if [ -f "$HOME/.bashrc" ]; then
  # shellcheck disable=SC1091
  source "$HOME/.bashrc"
fi

# Execute run_once_* scripts that haven't been executed yet
echo "==> Checking and executing run_once scripts..."

# Wait for chezmoi's lock to be released after apply
for wait_time in 1 2 3; do
  sleep "$wait_time"
  if chezmoi state data --source="$SRC" --destination="$DEST" > /dev/null 2>&1; then
    break
  fi
done

for script in "$SRC"/home/run_once_[0-9]*.sh.tmpl; do
  if [ ! -f "$script" ]; then
    continue
  fi

  script_name=$(basename "$script" .tmpl)
  # chezmoi stores execution state using the destination path as key
  # The key format is "/{destination}/{script_name_without_run_once_prefix}.sh"
  # Example: "/root/265-terminal-zellij.sh" for "run_once_265-terminal-zellij.sh.tmpl"
  script_key="/${DEST#/}/${script_name#run_once_}.sh"

  # Check if script has already been executed by checking chezmoi's state database
  # chezmoi stores script execution state in scriptState bucket
  # Also check if the tool is actually installed (in case previous execution failed)
  # Wait for lock to be released and retry with delays to avoid lock issues
  already_executed=0
  state_check_success=0

  # Check chezmoi state (with minimal retry for lock issues)
  # Most of the time, this succeeds on the first attempt
  # We only retry once if there's a brief lock contention after chezmoi apply
  for i in {1..2}; do
    if [ "$i" -gt 1 ]; then
      sleep 0.5
    fi
    if chezmoi state get --bucket=scriptState --key="$script_key" --source="$SRC" --destination="$DEST" > /dev/null 2>&1; then
      state_check_success=1
      break
    fi
  done

  # If state check succeeded, verify the tool is actually installed
  if [ $state_check_success -eq 1 ]; then
    # Extract tool name from script name (e.g., "run_once_275-utils-yq.sh" -> "yq")
    # Special cases:
    # - run_once_210-shell-cargo-tools.sh: multiple tools, handled separately
    # - run_once_100-runtimes-rust.sh: rustup/rustc/cargo, handled separately
    tool_name=""
    if [[ "$script_name" =~ run_once_[0-9]+-.*-([^\.]+)\.sh$ ]]; then
      tool_name="${BASH_REMATCH[1]}"
      # Special case: cargo-tools script contains multiple tools
      if [ "$tool_name" = "tools" ] && [[ "$script_name" =~ cargo-tools ]]; then
        tool_name="cargo-tools" # Mark as special case for case statement
      fi
    fi

    # Check if tool is actually installed (location depends on tool type)
    tool_installed=0
    # Check by script name first (for special cases like cargo-tools)
    case "$script_name" in
      *-fzf.sh)
        if [ -f "$HOME/.fzf/bin/fzf" ] || command -v fzf > /dev/null 2>&1; then
          tool_installed=1
        fi
        ;;
      *-runtimes-rust.sh)
        # Rust is installed if rustup, rustc, or cargo is available
        # Also check for .rustup and .cargo directories
        if command -v rustup > /dev/null 2>&1 ||
          command -v rustc > /dev/null 2>&1 ||
          command -v cargo > /dev/null 2>&1 ||
          [ -d "$HOME/.rustup" ] ||
          [ -d "$HOME/.cargo" ]; then
          tool_installed=1
        fi
        ;;
      *-shell-cargo-tools.sh)
        # Check for individual cargo-installed tools (by binary name)
        # These tools are installed via cargo install/cargo-binstall
        # Binary names: bat, eza, fd (from fd-find), rg (from ripgrep), starship, zoxide
        cargo_tools=("bat" "eza" "fd" "rg" "starship" "zoxide")
        all_installed=1
        for tool in "${cargo_tools[@]}"; do
          if ! command -v "$tool" > /dev/null 2>&1 &&
            ! [ -f "$HOME/.cargo/bin/$tool" ]; then
            all_installed=0
            break
          fi
        done
        if [ $all_installed -eq 1 ]; then
          tool_installed=1
        fi
        ;;
      *-runtimes-nodejs.sh | *-nodejs.sh)
        if command -v node > /dev/null 2>&1; then
          tool_installed=1
        fi
        ;;
      *-runtimes-python-uv.sh | *-python-uv.sh)
        if [ -f "$HOME/.local/bin/uv" ] || command -v uv > /dev/null 2>&1; then
          tool_installed=1
        fi
        ;;
      *-devtools-gh.sh)
        if command -v gh > /dev/null 2>&1; then
          tool_installed=1
        fi
        ;;
      *)
        # Fallback to tool name check if script name doesn't match special cases
        if [ -n "$tool_name" ]; then
          if [ -f "$HOME/.local/bin/$tool_name" ] || command -v "$tool_name" > /dev/null 2>&1; then
            tool_installed=1
          fi
        fi
        ;;
    esac

    if [ $tool_installed -eq 1 ]; then
      echo "  Skipping $script_name (already executed and installed)"
      already_executed=1
    elif [ -n "$tool_name" ]; then
      echo "  Note: $script_name marked as executed but tool not found ($tool_name), re-running installation..."
      sleep 0.5
      if ! state_delete_err=$(chezmoi state delete --bucket=scriptState --key="$script_key" --source="$SRC" --destination="$DEST" 2>&1); then
        echo "Warning: Failed to delete chezmoi state for $script_key" >&2
        if [ -n "$state_delete_err" ]; then
          printf '%s\n' "$state_delete_err" >&2
        fi
      fi
    else
      echo "  Skipping $script_name (already executed)"
      already_executed=1
    fi
  fi

  if [ $already_executed -eq 1 ]; then
    continue
  fi

  # Execute the script using chezmoi's template execution
  echo "  Executing $script_name..."
  script_output=$(chezmoi execute-template --source="$SRC" --destination="$DEST" < "$script" 2>&1)
  script_exit_code=0
  echo "$script_output" | bash || script_exit_code=$?
  if [ $script_exit_code -eq 0 ]; then
    echo "  ✓ $script_name completed successfully"
  else
    echo "  Error: Failed to execute $script_name (exit code: $script_exit_code)" >&2
    echo "$script_output" >&2
    # Check if the error is due to GitHub API rate limit
    if echo "$script_output" | grep -qiE "(rate limit|403|429)"; then
      echo "  Warning: This appears to be a GitHub API rate limit error." >&2
      echo "  Check rate limit status: curl -s https://api.github.com/rate_limit | jq '.rate'" >&2
      echo "  Wait for the limit to reset before retrying (see x-ratelimit-reset header)." >&2
      echo "  See: https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api" >&2
    fi
    exit 1
  fi
done

echo "✓ All run_once scripts processed"
