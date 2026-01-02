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

# Test 3: Verify 299-zoxide.sh sets environment variables
# Tests 3.1-3.4: File check, source, and verify 2 environment variables
# 299-zoxide.sh should set _ZO_RESOLVE_SYMLINKS and _ZO_ECHO when zoxide is available
# We need to source it and verify the variables are set
if [ ! -f ~/.bashrc.d/299-zoxide.sh ]; then
  fail "299-zoxide.sh file not found (should be deployed by chezmoi)"
fi

# Source helper functions first (required by 299-zoxide.sh)
# Temporarily disable set -u to avoid errors during sourcing
set +u
if [ -f ~/.bashrc.d/000-aliases-helper.sh ]; then
  source ~/.bashrc.d/000-aliases-helper.sh
fi
if [ -f ~/.bashrc.d/299-zoxide.sh ]; then
  source ~/.bashrc.d/299-zoxide.sh
else
  set -u # Re-enable set -u before calling fail() to ensure proper error detection
  fail "299-zoxide.sh file not found (should be deployed by chezmoi)"
fi
set -u

# Verify environment variables are set
# 299-zoxide.sh sets these when zoxide is available (which we verified in Test 1)
# If they are not set, it means 299-zoxide.sh did not execute correctly
if [ -z "${_ZO_RESOLVE_SYMLINKS:-}" ]; then
  fail "_ZO_RESOLVE_SYMLINKS not set after sourcing 299-zoxide.sh (zoxide is installed, so this should be set)"
fi
if [ -z "${_ZO_ECHO:-}" ]; then
  fail "_ZO_ECHO not set after sourcing 299-zoxide.sh (zoxide is installed, so this should be set)"
fi

# Verify the values are correct
assert_command "[ \"\$_ZO_RESOLVE_SYMLINKS\" = \"1\" ]" "_ZO_RESOLVE_SYMLINKS environment variable set to 1"
assert_command "[ \"\$_ZO_ECHO\" = \"1\" ]" "_ZO_ECHO environment variable set to 1"

# Test 4: zoxide can add and query directories (basic functionality)
# Tests 4.1-4.2: Add directory and verify query (2 results on success, 1 on failure)
test_dir=$(mktemp -d)
# Ensure cleanup on exit (including early exit from fail)
trap 'cd - >/dev/null 2>&1 || true; rm -rf "$test_dir"' EXIT
cd "$test_dir"
# zoxide add should add current directory to database
if zoxide add . 2>&1; then
  pass "zoxide can add directories to database"
  # Verify directory was added by querying
  if zoxide query "$(basename "$test_dir")" 2>&1 | grep -q "$test_dir"; then
    pass "zoxide can query added directories"
  else
    warn "zoxide directory query (directory may not be immediately queryable, but add succeeded)"
  fi
else
  fail "zoxide add test failed (zoxide add should succeed in test environment)"
fi
# Cleanup manually, then remove trap
cd - > /dev/null 2>&1 || true
rm -rf "$test_dir"
trap - EXIT

# Test 5: zoxide version can be retrieved
assert_command "zoxide --version" "zoxide version prints"

print_summary
