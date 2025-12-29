#!/usr/bin/env bash
# Test chezmoi dotfiles manager installation and functionality
# Usage: bash tests/chezmoi-test.sh

set -euo pipefail

# Import test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing chezmoi"
echo "=========================================="

# Test 1: Check if chezmoi is installed
assert_executable "chezmoi" "chezmoi installed"

# Test 2: Check chezmoi version
assert_command "chezmoi --version" "chezmoi version prints"

# Test 3: Check chezmoi help works
assert_command "chezmoi help" "chezmoi help works"

# Test 4: Check chezmoi can show data
assert_command "chezmoi data" "chezmoi data command works"

echo ""
print_summary
