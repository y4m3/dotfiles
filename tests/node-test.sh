#!/usr/bin/env bash
# Test Node.js installation (NodeSource or Volta)
# Usage: bash tests/node-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing Node.js Tooling"
echo "=========================================="

# node/npm/npx should be available
assert_executable "node" "node installed"
assert_executable "npm" "npm installed"
assert_executable "npx" "npx installed"

# version outputs
assert_command "node -v" "node version prints"
assert_command "npm -v" "npm version prints"

# Verify Node.js major version is 22 or higher
node_version=$(node -v | sed 's/v//')
node_major=$(echo "$node_version" | cut -d. -f1)
assert_command "[ \"$node_major\" -ge 22 ]" "Node.js version 22 or higher (current: $node_version)"

print_summary
