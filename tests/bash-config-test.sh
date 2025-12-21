#!/usr/bin/env bash
# Core bash configuration tests
# Validates environment setup, locale, colors, and prompt configuration
# Usage: ./tests/bash-config-test.sh
# Or from Docker: bash tests/bash-config-test.sh

set -euo pipefail

# Import test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing Bash Configuration"
echo "=========================================="

# Create temporary directory once for all tests
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Test 1: PATH includes home bin entries
# Source the paths configuration and check PATH
source ~/.bashrc.d/20-paths.sh 2> /dev/null
assert_string_contains "$PATH" "$HOME/.local/bin" "PATH includes \$HOME/.local/bin"

# Test 2: Locale is UTF-8
# Check system locale (already set by Docker)
assert_string_contains "$LANG" "UTF-8" "Locale LANG is UTF-8"

# Test 3: bash-completion is available (check if file is present)
if [ -f /usr/share/bash-completion/bash_completion ] || [ -f /etc/bash_completion ]; then
  pass "bash-completion available"
else
  fail "bash-completion not available"
fi

# Test 4: Prompt files are deployed
assert_file_exists "$HOME/.bash_prompt.d/bare.sh" "Bare prompt file deployed"
assert_file_exists "$HOME/.bash_prompt.d/enhanced.sh" "Enhanced prompt file deployed"

# Test 5: Terminal supports colors
tput colors > "$tmpdir/colors.out" 2> "$tmpdir/colors.err" || echo "0" > "$tmpdir/colors.out"
color_count=$(cat "$tmpdir/colors.out")
if [ "$color_count" -ge 16 ]; then
  pass "Terminal supports 16+ colors"
else
  warn "Terminal reports only $color_count colors"
fi

# Test 6: Timezone is set to JST
source ~/.bashrc.d/10-user-preferences.sh 2> /dev/null
assert_command "[ \"$TZ\" = 'Asia/Tokyo' ]" "Timezone set to JST (Asia/Tokyo)"

# Test 7: bash_profile exists
assert_file_exists "$HOME/.bashrc" "bashrc deployed"

echo ""
print_summary
