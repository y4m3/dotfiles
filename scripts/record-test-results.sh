#!/usr/bin/env bash
# Record test results in JSON format
# Usage: bash scripts/record-test-results.sh [--baseline]
#   --baseline: Save as baseline.json instead of latest.json

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RESULTS_DIR="$REPO_ROOT/.test-results"
HISTORY_DIR="$RESULTS_DIR/history"

# Create directories if they don't exist
mkdir -p "$RESULTS_DIR" "$HISTORY_DIR"

# Check if --baseline flag is set
is_baseline=false
if [ "${1:-}" = "--baseline" ]; then
  is_baseline=true
fi

# Get git commit hash (if in git repo)
git_commit=""
if git rev-parse --git-dir > /dev/null 2>&1; then
  git_commit=$(git rev-parse HEAD 2> /dev/null || echo "")
fi

# Get current timestamp
timestamp=$(date -Iseconds 2> /dev/null || date '+%Y-%m-%dT%H:%M:%S%z')

# Initialize JSON structure
json_output=$(
  cat << EOF
{
  "timestamp": "$timestamp",
  "git_commit": "${git_commit:-unknown}",
  "test_type": "${TEST_TYPE:-unknown}",
  "tests": {},
  "config_hashes": {},
  "summary": {
    "total": 0,
    "passed": 0,
    "failed": 0
  }
}
EOF
)

# If test results file exists, read it
# This script is typically called after tests run, so we expect results to be passed
# For now, we'll create a basic structure that can be extended

# Save to appropriate file
if [ "$is_baseline" = "true" ]; then
  output_file="$RESULTS_DIR/baseline.json"
  echo "Saving baseline test results to $output_file"
else
  output_file="$RESULTS_DIR/latest.json"
  echo "Saving test results to $output_file"
fi

# Also save to history with timestamp
history_file="$HISTORY_DIR/test-results-$(date +%Y%m%d-%H%M%S).json"

echo "$json_output" > "$output_file"
echo "$json_output" > "$history_file"

echo "Test results saved to $output_file"
echo "History saved to $history_file"
