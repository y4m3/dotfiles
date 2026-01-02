#!/usr/bin/env bash
# Record test results in JSON format
# Usage: bash scripts/record-test-results.sh [--baseline]
#   --baseline: Also save as baseline.json (latest.json is always written)
# Environment variables:
#   STRICT_RESULTS=1: Fail if any JSONL line is invalid JSON or missing required keys
#                    Default: skip invalid JSONL lines (best-effort mode)

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

# Check if jq is available (required for JSON processing)
if ! command -v jq > /dev/null 2>&1; then
  echo "Error: jq is required for recording test results" >&2
  exit 1
fi

# Results input (JSON Lines): exported by Makefile
TEST_RESULTS_JSONL="${TEST_RESULTS_JSONL:-}"
if [ -z "$TEST_RESULTS_JSONL" ] || [ ! -f "$TEST_RESULTS_JSONL" ]; then
  echo "Error: TEST_RESULTS_JSONL is not set or file not found: ${TEST_RESULTS_JSONL:-<empty>}" >&2
  exit 1
fi

# Strict mode:
# - STRICT_RESULTS=1: fail if any JSONL line is invalid JSON
# - default (0): skip invalid JSONL lines (best-effort)
STRICT_RESULTS="${STRICT_RESULTS:-0}"

# Get git commit hash (if in git repo)
git_commit=""
if git rev-parse --git-dir > /dev/null 2>&1; then
  git_commit=$(git rev-parse HEAD 2> /dev/null || echo "")
fi

# Get current timestamp
timestamp=$(date -Iseconds 2> /dev/null || date '+%Y-%m-%dT%H:%M:%S%z')

# Collect config hashes (low-cost, key files only)
# Keys are absolute paths for clarity.
declare -a CONFIG_FILES=(
  "$HOME/.bashrc"
  "$HOME/.bash_profile"
  "$HOME/.gitconfig"
  "$HOME/.config/starship.toml"
  "$HOME/.config/zellij/config.kdl"
)

config_hashes_json="$(
  for f in "${CONFIG_FILES[@]}"; do
    if [ -f "$f" ]; then
      hash=$(sha256sum "$f" | awk '{print $1}')
      printf '%s\t%s\n' "$f" "sha256:$hash"
    fi
  done | jq -Rn '
    [inputs | select(length>0) | split("\t") | {(.[0]): .[1]}] | add // {}
  '
)"

tests_json="$(
  jq -Rn --arg strict "$STRICT_RESULTS" '
    ($strict == "1") as $strict |
    def parse_line:
      # Drop empty/whitespace-only lines
      select(test("^\\s*$") | not)
      | try fromjson catch (
          if $strict then
            error("Invalid JSONL line: " + .)
          else
            empty
          end
        );

    def validate($t):
      if ($t | type) != "object" then
        if $strict then error("Invalid JSONL object") else empty end
      elif ($t | has("name") and has("status")) | not then
        if $strict then error("Missing required keys in JSONL object") else empty end
      else
        $t
      end;

    [inputs | parse_line | validate(.)]
    | reduce .[] as $t ({}; . + { ($t.name): {
        status: $t.status,
        duration_seconds: ($t.duration_seconds // 0),
        warn_count: ($t.warn_count // 0),
        log_file: ($t.log_file // "")
      }})
  ' < "$TEST_RESULTS_JSONL"
)"

summary_json="$(
  jq -n --argjson tests "$tests_json" '
    ($tests | keys) as $keys |
    {
      total: ($keys | length),
      passed: ($keys | map(select($tests[.].status == "pass")) | length),
      failed: ($keys | map(select($tests[.].status == "fail")) | length),
      warned: ($keys | map(($tests[.].warn_count // 0)) | add // 0)
    }
  '
)"

json_output="$(
  jq -n \
    --arg timestamp "$timestamp" \
    --arg git_commit "${git_commit:-unknown}" \
    --arg test_type "${TEST_TYPE:-unknown}" \
    --argjson tests "$tests_json" \
    --argjson config_hashes "$config_hashes_json" \
    --argjson summary "$summary_json" \
    '{
      timestamp: $timestamp,
      git_commit: $git_commit,
      test_type: $test_type,
      tests: $tests,
      config_hashes: $config_hashes,
      summary: $summary
    }'
)"

# Always save latest.json
latest_file="$RESULTS_DIR/latest.json"
echo "Saving test results to $latest_file"

# Also save to history with timestamp
history_file="$HISTORY_DIR/test-results-$(date +%Y%m%d-%H%M%S).json"

echo "$json_output" > "$latest_file"
echo "$json_output" > "$history_file"

echo "Test results saved to $latest_file"
echo "History saved to $history_file"

# Additionally save baseline.json if requested
if [ "$is_baseline" = "true" ]; then
  baseline_file="$RESULTS_DIR/baseline.json"
  echo "Saving baseline test results to $baseline_file"
  echo "$json_output" > "$baseline_file"
  echo "Baseline saved to $baseline_file"
fi
