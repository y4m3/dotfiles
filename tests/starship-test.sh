#!/usr/bin/env bash
# Test starship installation and configuration
# Usage: bash tests/starship-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing starship"
echo "=========================================="

# Ensure ~/.cargo/bin is in PATH
case ":$PATH:" in
  *":$HOME/.cargo/bin:"*) : ;;
  *) PATH="$HOME/.cargo/bin:$PATH" ;;
esac

# Level 1: Basic verification
assert_executable "starship" "starship installed"
assert_command "starship --version" "starship version prints"
assert_file_exists "$HOME/.config/starship.toml" "starship config deployed"

# Level 2: Config validation
# starship config validates the config file by trying to parse it
# Use starship prompt with a simple command to verify config is parseable
# Note: Level 2 target guideline is 1-2 seconds, but starship prompt may take time to load
# modules and initialize. Using 5 seconds as a reasonable compromise for config validation.
set +e
starship_output=$(timeout 5 starship prompt --status 0 --cmd-duration 0 2>&1)
starship_exit=$?
set -e
if [ $starship_exit -eq 124 ]; then
  # Timeout occurred - cannot verify config validity
  fail "starship prompt generation timed out after 5 seconds (cannot verify config is valid)"
elif [ $starship_exit -ne 0 ]; then
  # Command failed - check if it's a config parsing error
  # Look for specific error patterns that indicate config issues:
  # - Lines starting with "error:" or "Error:" (definitive error indicator)
  # - "parse" or "syntax" errors in config context (must mention both config and error)
  # - "invalid" in config context (not in branch names, etc.)
  if echo "${starship_output:-}" | grep -qE "^(error|Error):|((parse|Parse|syntax).*(config|Config).*(error|Error)|(error|Error).*(config|Config).*(parse|Parse|syntax))|(invalid|Invalid).*(config|Config|file|File)"; then
    fail "starship config has errors: ${starship_output:-}"
  else
    # Unknown failure - cannot verify config validity, so fail
    fail "starship prompt generation failed with exit code $starship_exit (cannot verify config is valid): ${starship_output:-}"
  fi
else
  # Command succeeded - config is parseable
  # No need to check output for errors when exit code is 0
  # (starship would exit non-zero if there were config errors)
  pass "starship config is valid (parseable)"
fi

print_summary
