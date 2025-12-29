#!/usr/bin/env bash
set -euo pipefail

SRC=${1:-/workspace}
DEST=${2:-/root}

# Apply dotfiles configuration
find "$HOME/.config/chezmoi" -name "*.lock" -type f -delete 2> /dev/null || true

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
if [ -f "$HOME/.bash_profile" ]; then
  source "$HOME/.bash_profile"
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
    tool_name=""
    if [[ "$script_name" =~ run_once_[0-9]+-.*-([^\.]+)\.sh$ ]]; then
      tool_name="${BASH_REMATCH[1]}"
    fi

    # Check if tool is actually installed (location depends on tool type)
    tool_installed=0
    if [ -n "$tool_name" ]; then
      case "$script_name" in
        *-fzf.sh)
          if [ -f "$HOME/.fzf/bin/fzf" ] || command -v fzf > /dev/null 2>&1; then
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
          if [ -f "$HOME/.local/bin/$tool_name" ] || command -v "$tool_name" > /dev/null 2>&1; then
            tool_installed=1
          fi
          ;;
      esac
    fi

    if [ $tool_installed -eq 1 ]; then
      echo "  Skipping $script_name (already executed and installed)"
      already_executed=1
    elif [ -n "$tool_name" ]; then
      echo "  Note: $script_name marked as executed but tool not found ($tool_name), re-running installation..."
      sleep 0.5
      chezmoi state delete --bucket=scriptState --key="$script_key" --source="$SRC" --destination="$DEST" 2> /dev/null || true
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
  if echo "$script_output" | bash; then
    echo "  ✓ $script_name completed successfully"
  else
    echo "  Error: Failed to execute $script_name" >&2
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
