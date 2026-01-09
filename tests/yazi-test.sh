#!/usr/bin/env bash
# Test yazi installation
# Usage: bash tests/yazi-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing yazi"
echo "=========================================="

case ":$PATH:" in
  *":$HOME/.local/bin:"*) : ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

assert_executable "yazi" "yazi installed"
assert_command "yazi --version" "yazi version prints"
assert_executable "ya" "ya (plugin manager) installed"
assert_command "ya --version" "ya version prints"

# Config files exist (deployed by chezmoi)
assert_file_exists "$HOME/.config/yazi/yazi.toml" "yazi config file deployed"
assert_file_exists "$HOME/.config/yazi/keymap.toml" "yazi keymap config deployed"

print_summary
