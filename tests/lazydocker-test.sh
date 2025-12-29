#!/usr/bin/env bash
# Test lazydocker installation
# Usage: bash tests/lazydocker-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing lazydocker"
echo "=========================================="

case ":$PATH:" in
  *":$HOME/.local/bin:") : ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

assert_executable "lazydocker" "lazydocker installed"
assert_command "lazydocker --version" "lazydocker version prints"

# Test 3: lazydocker config file exists (deployed by chezmoi)
assert_file_exists "$HOME/.config/lazydocker/config.yml" "lazydocker config file deployed"

print_summary
