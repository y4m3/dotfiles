#!/usr/bin/env bash
# Test lazygit installation
# Usage: bash tests/lazygit-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing lazygit"
echo "=========================================="

# Ensure ~/.local/bin is in PATH
case ":$PATH:" in
  *":$HOME/.local/bin:") : ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

assert_executable "lazygit" "lazygit installed"
assert_command "lazygit --version" "lazygit version prints"

print_summary
