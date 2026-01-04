#!/usr/bin/env bash
# Test wezterm installation
# Usage: bash tests/wezterm-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing wezterm"
echo "=========================================="

# Test: wezterm executable exists
assert_executable "wezterm" "wezterm installed"

# Test: wezterm version prints
assert_command "wezterm --version" "wezterm version prints"

# Test: systemd service file exists
assert_file_exists "$HOME/.config/systemd/user/wezterm-mux.service" "wezterm mux service file exists"

# Test: wezterm config file exists
assert_file_exists "$HOME/.config/wezterm/wezterm.lua" "wezterm config file exists"

# Note: systemd service functionality cannot be tested in Docker (no systemd)
# The service file existence is verified above

print_summary
