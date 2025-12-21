#!/usr/bin/env bash
# Test zoxide setup and integration
# Usage: bash tests/zoxide-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing zoxide Integration"
echo "=========================================="

# Test 1: zoxide binary is installed
export PATH="/root/.cargo/bin:$PATH"
assert_executable "zoxide" "zoxide binary installed"

# Test 2: zoxide can run basic command (may be empty on first run)
assert_command "zoxide query -l" "zoxide query command works"

# Test 3: Verify 60-utils.sh sets environment variables
source ~/.bashrc.d/60-utils.sh 2>/dev/null
assert_command "[ \"$_ZO_RESOLVE_SYMLINKS\" = \"1\" ]" "_ZO_RESOLVE_SYMLINKS environment variable set"
assert_command "[ \"$_ZO_ECHO\" = \"1\" ]" "_ZO_ECHO environment variable set"

print_summary

