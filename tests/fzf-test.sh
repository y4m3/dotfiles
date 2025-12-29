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

# Test 4: fzf can filter input (non-interactive mode)
output=$(echo -e "test1\ntest2\ntest3" | fzf -f test2 2> /dev/null || true)
assert_string_contains "$output" "test2" "fzf can filter input"

print_summary
