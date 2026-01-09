#!/usr/bin/env bash
# Test Go installation
# Usage: bash tests/go-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing Go"
echo "=========================================="

# Set GOROOT and ensure PATH includes Go binaries
GOROOT="${GOROOT:-$HOME/.local/go}"
case ":$PATH:" in
    *":$GOROOT/bin:"*) : ;;
    *) PATH="$GOROOT/bin:$PATH" ;;
esac

assert_executable "go" "go installed"
assert_command "go version" "go version prints"

print_summary
