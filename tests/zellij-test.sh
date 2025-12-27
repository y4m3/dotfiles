#!/usr/bin/env bash
# Test zellij installation
# Usage: bash tests/zellij-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing zellij"
echo "=========================================="

case ":$PATH:" in
  *":$HOME/.local/bin:") : ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

assert_executable "zellij" "zellij installed"
assert_command "zellij --version" "zellij version prints"

print_summary
