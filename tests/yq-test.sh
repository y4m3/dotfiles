#!/usr/bin/env bash
# Test yq installation
# Usage: bash tests/yq-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing yq"
echo "=========================================="

GOBIN="${GOBIN:-$HOME/go/bin}"
case ":$PATH:" in
    *":$GOBIN:"*) : ;;
    *) PATH="$GOBIN:$PATH" ;;
esac

assert_executable "yq" "yq installed"
assert_command "yq --version" "yq version prints"

# Basic YAML extraction
output=$(printf 'a: 1\n' | yq '.a')
assert_string_contains "$output" "1" "yq parses yaml"

print_summary
