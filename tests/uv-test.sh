#!/usr/bin/env bash
# Test uv installation
# Usage: bash tests/uv-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing uv (Python package manager)"
echo "=========================================="

# Ensure ~/.local/bin is in PATH
case ":$PATH:" in
  *":$HOME/.local/bin:"*) : ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

# Test 1: uv is installed
assert_executable "uv" "uv installed"

# Test 2: uv version can be retrieved
assert_command "uv --version" "uv version check successful"

# Test 3: uv help works
assert_command "uv --help | grep -q 'Usage:'" "uv help command works"

# Test 4: uv can list Python versions
assert_command "uv python list" "uv can list Python versions"

echo ""
print_summary
