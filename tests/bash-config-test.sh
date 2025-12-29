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

# Test 7: bashrc exists
assert_file_exists "$HOME/.bashrc" "bashrc deployed"

# Test 8: starship config exists and is valid
assert_file_exists "$HOME/.config/starship.toml" "starship config deployed"
if command -v starship > /dev/null 2>&1; then
  # starship config is an editor command (opens vim), not a validation command
  # Instead, validate by checking if starship can parse the config file
  # We can do this by trying to generate a prompt (which requires parsing the config)
  # or by using a TOML parser to validate syntax
  # Use starship prompt with a simple command to verify config is parseable
  # Note: Level 2 guideline is 1-2 seconds, but starship prompt may take time to load
  # modules and initialize. Using 5 seconds as a reasonable compromise. If testing shows
  # it consistently completes faster, this can be reduced to 2-3 seconds.
  set +e
  starship_output=$(timeout 5 starship prompt --status 0 --cmd-duration 0 2>&1)
  starship_exit=$?
  set -e
  if [ $starship_exit -eq 124 ]; then
    # Timeout occurred - cannot verify config validity
    fail "starship prompt generation timed out after 5 seconds (cannot verify config is valid)"
  elif [ $starship_exit -ne 0 ]; then
    # Command failed - check if it's a config parsing error
    if echo "${starship_output:-}" | grep -qE "(error|Error|invalid|Invalid|parse|Parse|syntax)"; then
      fail "starship config has errors: ${starship_output:-}"
    else
      # Unknown failure - cannot verify config validity, so fail
      fail "starship prompt generation failed with exit code $starship_exit (cannot verify config is valid): ${starship_output:-}"
    fi
  else
    # Command succeeded - config is parseable
    # Check output for any error messages
    if echo "${starship_output:-}" | grep -qE "(error|Error|invalid|Invalid)"; then
      fail "starship config has errors: ${starship_output:-}"
    else
      pass "starship config is valid (parseable)"
    fi
  fi
else
  # starship is installed by run_once_210-shell-cargo-tools.sh.tmpl, so it should be present
  fail "starship not found (should be installed by run_once script)"
fi

# Test 9: zellij config exists and is valid
assert_file_exists "$HOME/.config/zellij/config.kdl" "zellij config deployed"
if command -v zellij > /dev/null 2>&1; then
  # zellij setup --check validates the config file
  # Use timeout to prevent hanging, but treat timeout as failure since we cannot verify validity
  # In non-interactive environments (like tests), zellij setup --check may hang waiting for TTY input
  # Redirect stdin from /dev/null to prevent interactive prompts
  # Note: Level 2 guideline is 1-2 seconds, but zellij setup --check may take longer
  # in some environments (file system checks, plugin validation). Using 10 seconds as
  # a reasonable compromise between detection speed and false failures.
  set +e
  zellij_output=$(timeout 10 zellij setup --check < /dev/null 2>&1)
  zellij_exit=$?
  set -e
  if [ $zellij_exit -eq 124 ]; then
    # Timeout occurred (exit code 124 from timeout command)
    # If validation times out, we cannot verify the config is valid
    fail "zellij setup --check timed out after 10 seconds (cannot verify config is valid)"
  elif [ $zellij_exit -ne 0 ]; then
    # Command failed (non-zero exit code)
    if echo "${zellij_output:-}" | grep -qE "(error|Error|invalid|Invalid|failed|Failed|syntax)"; then
      fail "zellij config has syntax errors: ${zellij_output:-}"
    else
      # Unknown failure - treat as error since we cannot verify config validity
      fail "zellij setup --check failed with exit code $zellij_exit (cannot verify config is valid): ${zellij_output:-}"
    fi
  else
    # Command succeeded (exit code 0)
    # Check output for any error messages
    if echo "${zellij_output:-}" | grep -qE "(error|Error|invalid|Invalid|failed|Failed|syntax)"; then
      fail "zellij config has syntax errors: ${zellij_output:-}"
    else
      pass "zellij config syntax is valid"
    fi
  fi
else
  # zellij is installed by run_once_265-terminal-zellij.sh.tmpl, so it should be present
  fail "zellij not found (should be installed by run_once script)"
fi

echo ""
print_summary
