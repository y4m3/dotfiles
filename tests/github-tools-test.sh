#!/usr/bin/env bash
# Test GitHub-related tools: gh and ghq
# Usage: bash tests/github-tools-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing GitHub Tools (gh, ghq)"
echo "=========================================="

# Ensure ~/.local/bin is in PATH for ghq
case ":$PATH:" in
  *":$HOME/.local/bin:"*) : ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

# gh installed
assert_executable "gh" "GitHub CLI (gh) installed"
assert_command "gh --version | command grep -q 'gh version'" "gh version prints"

# ghq installed (from Go install)
assert_executable "ghq" "ghq installed"
assert_command "ghq --version" "ghq version prints"

print_summary
