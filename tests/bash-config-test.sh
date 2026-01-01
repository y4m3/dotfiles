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
if ! source ~/.bashrc.d/20-paths.sh 2>&1; then
  fail "Failed to source ~/.bashrc.d/20-paths.sh"
fi
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
# Tests 4.1-4.2: Check 2 prompt files
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
if ! source ~/.bashrc.d/10-user-preferences.sh 2>&1; then
  fail "Failed to source ~/.bashrc.d/10-user-preferences.sh"
fi
assert_command "[ \"$TZ\" = 'Asia/Tokyo' ]" "Timezone set to JST (Asia/Tokyo)"

# Test 7: bashrc exists
assert_file_exists "$HOME/.bashrc" "bashrc deployed"

# Test 8: Verify that required config files exist and are readable
# Tests 8.1-8.2: Check 2 config files
for config_file in "$HOME/.bashrc" "$HOME/.bashrc.d/20-paths.sh"; do
  if [ ! -f "$config_file" ]; then
    fail "Required config file missing: $config_file"
  elif [ ! -r "$config_file" ]; then
    fail "Required config file not readable: $config_file"
  else
    pass "Config file exists and is readable: $config_file"
  fi
done

# Test 9: Verify bashrc.d scripts can be sourced without errors
# Source each script and verify no errors occur
bashrc_d_scripts=$(find "$HOME/.bashrc.d" -name "*.sh" -type f 2> /dev/null | sort)
if [ -z "$bashrc_d_scripts" ]; then
  warn "No bashrc.d scripts found to test"
else
  script_count=0
  error_count=0
  while IFS= read -r script; do
    script_count=$((script_count + 1))
    if ! bash -n "$script" 2>&1; then
      error_count=$((error_count + 1))
      fail "Syntax error in bashrc.d script: $script"
    fi
  done <<< "$bashrc_d_scripts"
  if [ $error_count -eq 0 ]; then
    pass "All $script_count bashrc.d scripts have valid syntax"
  fi
fi

echo ""
print_summary
