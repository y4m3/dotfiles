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
  *":$HOME/.local/bin:") : ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

assert_executable "yazi" "yazi installed"
assert_command "yazi --version" "yazi version prints"

print_summary
