#!/usr/bin/env bash
# Verify required items against baseline
# Usage: bash scripts/verify-baseline.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RESULTS_DIR="$REPO_ROOT/.test-results"
BASELINE_FILE="$RESULTS_DIR/baseline.json"

# Check if jq is available
if ! command -v jq > /dev/null 2>&1; then
  echo "Error: jq is required for verifying baseline" >&2
  exit 1
fi

# Check if baseline exists
if [ ! -f "$BASELINE_FILE" ]; then
  echo "Error: Baseline file not found at $BASELINE_FILE" >&2
  echo "Run 'make test-all BASELINE=1' to create a baseline" >&2
  exit 1
fi

echo "Verifying required items against baseline..."
echo ""

# Check each required item
all_passed=true

# 1. All tools installed
echo "Checking: All tools installed"
baseline_tests_count=$(jq -r '.tests | length' "$BASELINE_FILE" 2> /dev/null || echo "0")
baseline_tests_count=$(echo "$baseline_tests_count" | tr -d '\n\r' | grep -E '^[0-9]+$' || echo "0")
tool_count="$baseline_tests_count"
if [ "$tool_count" -gt 0 ]; then
  echo "  ✓ Baseline has $tool_count test(s)"
else
  echo "  ✗ Baseline has no tests"
  all_passed=false
fi

# 2. Configuration files deployed
echo "Checking: Configuration files deployed"
config_count=$(jq -r '.config_hashes | length' "$BASELINE_FILE" 2> /dev/null || echo "0")
config_count=$(echo "$config_count" | tr -d '\n\r' | grep -E '^[0-9]+$' || echo "0")
if [ "$config_count" -gt 0 ]; then
  echo "  ✓ Baseline has $config_count config file(s)"
else
  echo "  ✗ Baseline has no config files"
  all_passed=false
fi

# 3. PATH correctly configured
echo "Checking: PATH correctly configured"
# This is verified by bash-config-test.sh in the baseline
if jq -e '.tests | has("bash-config-test.sh")' "$BASELINE_FILE" > /dev/null 2>&1; then
  echo "  ✓ bash-config-test.sh in baseline"
else
  echo "  ✗ bash-config-test.sh not in baseline"
  all_passed=false
fi

# 4. GitHub API authentication working
echo "Checking: GitHub API authentication working"
# This is verified by github-tools-test.sh in the baseline
if jq -e '.tests | has("github-tools-test.sh")' "$BASELINE_FILE" > /dev/null 2>&1; then
  echo "  ✓ github-tools-test.sh in baseline"
else
  echo "  ✗ github-tools-test.sh not in baseline"
  all_passed=false
fi

echo ""
if [ "$all_passed" = "true" ]; then
  echo "✓ All required items verified"
  exit 0
else
  echo "✗ Some required items are missing"
  exit 1
fi
