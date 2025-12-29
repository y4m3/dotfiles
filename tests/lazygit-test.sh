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

# Test 3: lazygit config file exists (deployed by chezmoi)
assert_file_exists "$HOME/.config/lazygit/config.yml" "lazygit config file deployed"

print_summary
