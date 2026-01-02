#!/usr/bin/env bash
# Test zellij installation
# Usage: bash tests/zellij-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing zellij"
echo "=========================================="

case ":$PATH:" in
  *":$HOME/.local/bin:"*) : ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

assert_executable "zellij" "zellij installed"
assert_command "zellij --version" "zellij version prints"

# Test 3: zellij config file exists and is valid
assert_file_exists "$HOME/.config/zellij/config.kdl" "zellij config file exists"

# Validate config syntax using zellij setup --check
# This is the authoritative way to validate zellij config files
# If it times out or fails, we cannot verify the config is valid, so we treat it as an error
# In non-interactive environments (like tests), zellij setup --check may hang waiting for TTY input
# Redirect stdin from /dev/null to prevent interactive prompts
# Note: Level 2 guideline is 1-2 seconds, but zellij setup --check may take longer
# in some environments (file system checks, plugin validation). Using 10 seconds as
# a reasonable compromise between detection speed and false failures.
set +e
check_output=$(timeout 10 zellij setup --check < /dev/null 2>&1)
check_exit=$?
set -e

if [ $check_exit -eq 124 ]; then
  # Timeout occurred (exit code 124 from timeout command)
  # If validation times out, we cannot verify the config is valid
  # This is a test failure because we cannot confirm the config works
  fail "zellij setup --check timed out after 10 seconds (cannot verify config is valid)"
elif [ $check_exit -ne 0 ]; then
  # Command failed (non-zero exit code)
  # Check if the output contains error messages
  if echo "${check_output:-}" | grep -qE "(error|Error|invalid|Invalid|failed|Failed|syntax)"; then
    fail "zellij config has syntax errors: ${check_output:-}"
  else
    # Unknown failure - treat as error since we cannot verify config validity
    fail "zellij setup --check failed with exit code $check_exit (cannot verify config is valid): ${check_output:-}"
  fi
else
  # Command succeeded (exit code 0)
  # Check output for any error messages (some tools return 0 even with warnings)
  if echo "${check_output:-}" | grep -qE "(error|Error|invalid|Invalid|failed|Failed|syntax)"; then
    fail "zellij config has syntax errors: ${check_output:-}"
  else
    # Success: config is valid
    pass "zellij config syntax is valid"
  fi
fi

print_summary
