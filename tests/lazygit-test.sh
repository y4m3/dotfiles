#!/usr/bin/env bash
# Test lazygit installation
# Usage: bash tests/lazygit-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing lazygit"
echo "=========================================="

# Ensure Go bin directory is in PATH
GOBIN="${GOBIN:-$HOME/go/bin}"
case ":$PATH:" in
    *":$GOBIN:"*) : ;;
    *) PATH="$GOBIN:$PATH" ;;
esac

assert_executable "lazygit" "lazygit installed"
assert_command "lazygit --version" "lazygit version prints"

# Test 3: lazygit config file exists (deployed by chezmoi)
assert_file_exists "$HOME/.config/lazygit/config.yml" "lazygit config file deployed"

print_summary
