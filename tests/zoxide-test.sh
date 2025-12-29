#!/usr/bin/env bash
# Test zoxide setup and integration
# Usage: bash tests/zoxide-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing zoxide Integration"
echo "=========================================="

# Ensure ~/.cargo/bin is in PATH
case ":$PATH:" in
  *":$HOME/.cargo/bin:"*) : ;;
  *) PATH="$HOME/.cargo/bin:$PATH" ;;
esac

# Test 1: zoxide binary is installed
assert_executable "zoxide" "zoxide binary installed"

# Test 2: zoxide can run basic command (may be empty on first run)
assert_command "zoxide query -l" "zoxide query command works"

# Test 3: Verify 60-utils.sh sets environment variables
# 60-utils.sh should set _ZO_RESOLVE_SYMLINKS and _ZO_ECHO when zoxide is available
# We need to source it and verify the variables are set
if [ ! -f ~/.bashrc.d/60-utils.sh ]; then
  fail "60-utils.sh file not found (should be deployed by chezmoi)"
fi

# Source the script to set environment variables
# Temporarily disable set -u to avoid errors during sourcing
set +u
source ~/.bashrc.d/60-utils.sh 2> /dev/null || true
set -u

# Verify environment variables are set
# 60-utils.sh sets these when zoxide is available (which we verified in Test 1)
# If they are not set, it means 60-utils.sh did not execute correctly
if [ -z "${_ZO_RESOLVE_SYMLINKS:-}" ]; then
  fail "_ZO_RESOLVE_SYMLINKS not set after sourcing 60-utils.sh (zoxide is installed, so this should be set)"
fi
if [ -z "${_ZO_ECHO:-}" ]; then
  fail "_ZO_ECHO not set after sourcing 60-utils.sh (zoxide is installed, so this should be set)"
fi

# Verify the values are correct
assert_command "[ \"\$_ZO_RESOLVE_SYMLINKS\" = \"1\" ]" "_ZO_RESOLVE_SYMLINKS environment variable set to 1"
assert_command "[ \"\$_ZO_ECHO\" = \"1\" ]" "_ZO_ECHO environment variable set to 1"

print_summary
