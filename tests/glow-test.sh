#!/usr/bin/env bash
# Test glow installation
# Usage: bash tests/glow-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing glow"
echo "=========================================="

case ":$PATH:" in
  *":$HOME/.local/bin:"*) : ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

assert_executable "glow" "glow installed"
assert_command "glow --version" "glow version prints"

# Test: glow can render markdown
tmpfile=$(mktemp)
echo "# Hello" > "$tmpfile"
assert_command "glow '$tmpfile'" "glow renders markdown"
rm -f "$tmpfile"

print_summary
