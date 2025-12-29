#!/usr/bin/env bash
# Test btop installation
# Usage: bash tests/btop-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing btop"
echo "=========================================="

case ":$PATH:" in
  *":$HOME/.local/bin:") : ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

assert_executable "btop" "btop installed"
assert_command "btop --version" "btop version prints"

# Test 3: btop config file exists (deployed by chezmoi)
assert_file_exists "$HOME/.config/btop/btop.conf" "btop config file deployed"

print_summary
