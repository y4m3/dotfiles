#!/usr/bin/env bash
# Test prerequisite tools installed via run_once_000-prerequisites.sh.tmpl
# Usage: bash tests/prerequisites-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing prerequisite tools (jq, tmux)"
echo "=========================================="

# Ensure jq is available
assert_executable "jq" "jq installed"
assert_command "jq --version" "jq version check successful"

# Ensure tmux is available
assert_executable "tmux" "tmux installed"
assert_command "tmux -V" "tmux version check successful"

print_summary
