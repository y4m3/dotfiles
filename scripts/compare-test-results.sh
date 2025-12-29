#!/usr/bin/env bash
# Compare current test results with baseline
# Usage: bash scripts/compare-test-results.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RESULTS_DIR="$REPO_ROOT/.test-results"
BASELINE_FILE="$RESULTS_DIR/baseline.json"
LATEST_FILE="$RESULTS_DIR/latest.json"

# Check if jq is available
if ! command -v jq > /dev/null 2>&1; then
  echo "Error: jq is required for comparing test results" >&2
  exit 1
fi

# Check if baseline exists
if [ ! -f "$BASELINE_FILE" ]; then
  echo "Warning: Baseline file not found at $BASELINE_FILE" >&2
  echo "Run 'make test-all BASELINE=1' to create a baseline" >&2
  exit 1
fi

# Check if latest results exist
if [ ! -f "$LATEST_FILE" ]; then
  echo "Warning: Latest test results not found at $LATEST_FILE" >&2
  exit 1
fi

echo "Comparing test results..."
echo "Baseline: $BASELINE_FILE"
echo "Latest: $LATEST_FILE"
echo ""

# Compare test results
baseline_tests=$(jq -r '.tests | keys[]' "$BASELINE_FILE" 2> /dev/null || echo "")
latest_tests=$(jq -r '.tests | keys[]' "$LATEST_FILE" 2> /dev/null || echo "")

regressions=0
improvements=0
new_tests=0
missing_tests=0

# Check for regressions (tests that passed in baseline but failed in latest)
while IFS= read -r test_name; do
  if [ -z "$test_name" ]; then
    continue
  fi

  baseline_status=$(jq -r ".tests[\"$test_name\"].status // \"unknown\"" "$BASELINE_FILE" 2> /dev/null || echo "unknown")
  latest_status=$(jq -r ".tests[\"$test_name\"].status // \"unknown\"" "$LATEST_FILE" 2> /dev/null || echo "unknown")

  if [ "$baseline_status" = "pass" ] && [ "$latest_status" = "fail" ]; then
    echo "REGRESSION: $test_name (was passing, now failing)"
    regressions=$((regressions + 1))
  elif [ "$baseline_status" = "fail" ] && [ "$latest_status" = "pass" ]; then
    echo "IMPROVEMENT: $test_name (was failing, now passing)"
    improvements=$((improvements + 1))
  fi
done <<< "$baseline_tests"

# Check for new tests
while IFS= read -r test_name; do
  if [ -z "$test_name" ]; then
    continue
  fi

  baseline_exists=$(jq -r ".tests[\"$test_name\"] // \"\"" "$BASELINE_FILE" 2> /dev/null || echo "")
  if [ -z "$baseline_exists" ]; then
    echo "NEW TEST: $test_name"
    new_tests=$((new_tests + 1))
  fi
done <<< "$latest_tests"

# Check for missing tests
while IFS= read -r test_name; do
  if [ -z "$test_name" ]; then
    continue
  fi

  latest_exists=$(jq -r ".tests[\"$test_name\"] // \"\"" "$LATEST_FILE" 2> /dev/null || echo "")
  if [ -z "$latest_exists" ]; then
    echo "MISSING TEST: $test_name (was in baseline, not in latest)"
    missing_tests=$((missing_tests + 1))
  fi
done <<< "$baseline_tests"

echo ""
echo "Summary:"
echo "  Regressions: $regressions"
echo "  Improvements: $improvements"
echo "  New tests: $new_tests"
echo "  Missing tests: $missing_tests"

if [ $regressions -gt 0 ]; then
  echo ""
  echo "ERROR: $regressions regression(s) detected!"
  exit 1
fi

if [ $missing_tests -gt 0 ]; then
  echo ""
  echo "WARNING: $missing_tests test(s) missing from latest results"
fi

exit 0
