#!/usr/bin/env bash
# Test fzf installation
# Usage: bash tests/fzf-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing fzf"
echo "=========================================="

# Ensure ~/.fzf/bin is in PATH
case ":$PATH:" in
  *":$HOME/.fzf/bin:"*) : ;;
  *) PATH="$HOME/.fzf/bin:$PATH" ;;
esac

# Test 1: fzf is installed
assert_executable "fzf" "fzf installed"

# Test 2: fzf version can be retrieved
assert_command "fzf --version" "fzf version prints"

# Test 3: fzf directory exists (check as directory, not file)
if [ -d "$HOME/.fzf" ]; then
  pass "fzf directory exists"
else
  fail "fzf directory exists (directory not found: $HOME/.fzf)"
fi

# Test 4: fzf can filter input (basic functionality test)
set +e
output=$(echo -e "test1\ntest2\ntest3" | fzf -f test2 2>&1)
fzf_exit=$?
set -e
# Exit code 1 means no match (acceptable for this test), other codes are errors
if [ $fzf_exit -ne 0 ] && [ $fzf_exit -ne 1 ]; then
  fail "fzf failed with exit code $fzf_exit: $output"
fi
assert_string_contains "$output" "test2" "fzf can filter input"

print_summary
