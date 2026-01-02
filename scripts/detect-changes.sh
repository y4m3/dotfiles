#!/usr/bin/env bash
# Detect which tests to run based on git diff
# Usage: bash scripts/detect-changes.sh [base_commit]
#   base_commit: Optional. If specified, compares between commits.
#                If not specified (default), detects uncommitted changes (HEAD vs working directory).
# Returns: space-separated list of test files to run, or empty string for all tests
# Environment variables:
#   DEBUG_DETECT_CHANGES=1: Print debug messages explaining why change detection falls back to running all tests
#                          Default: silent fallback (no debug output)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MAPPING_FILE="$REPO_ROOT/.test-mapping.json"

# Default: detect uncommitted changes (HEAD vs working directory)
# If base commit is specified, compare between commits
BASE_COMMIT="${1:-}"

# Check if mapping file exists
if [ ! -f "$MAPPING_FILE" ]; then
  echo "Error: .test-mapping.json not found" >&2
  exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  # In Docker with git worktrees, the working tree may be mounted without the actual gitdir.
  # In that case, change detection is unavailable and we should simply fall back to "run all tests"
  # without producing noisy output.
  if [ "${DEBUG_DETECT_CHANGES:-0}" = "1" ]; then
    echo "Debug: change detection unavailable (not a git repo). Falling back to running all tests." >&2
  fi
  exit 0
fi

# Get changed files
# If BASE_COMMIT is specified, compare between commits
# Otherwise, compare HEAD with working directory (uncommitted changes)
if [ -n "$BASE_COMMIT" ]; then
  changed_files=$(git diff --name-only "$BASE_COMMIT" HEAD 2> /dev/null || echo "")
else
  # Detect uncommitted changes (staged + unstaged)
  changed_files=$(git diff --name-only HEAD 2> /dev/null || echo "")
  # Also include staged changes
  staged_files=$(git diff --cached --name-only 2> /dev/null || echo "")
  if [ -n "$staged_files" ]; then
    changed_files=$(printf "%s\n%s" "$changed_files" "$staged_files" | sort -u)
  fi
fi

# If no changes detected, return empty (will run all tests)
if [ -z "$changed_files" ]; then
  exit 0
fi

# Check if jq is available (required for JSON parsing)
if ! command -v jq > /dev/null 2>&1; then
  # Change detection requires jq. If unavailable, fall back to running all tests.
  if [ "${DEBUG_DETECT_CHANGES:-0}" = "1" ]; then
    echo "Debug: change detection unavailable (jq not found). Falling back to running all tests." >&2
  fi
  exit 0
fi

# Collect tests to run
declare -A tests_to_run
affects_all=false

# Process each changed file
while IFS= read -r changed_file; do
  # Skip if file doesn't exist (deleted)
  if [ ! -f "$REPO_ROOT/$changed_file" ] && [ ! -d "$REPO_ROOT/$changed_file" ]; then
    continue
  fi

  # Check each mapping pattern
  mapping_count=$(jq '.mappings | length' "$MAPPING_FILE")
  if [ "$mapping_count" -le 0 ] 2> /dev/null; then
    continue
  fi

  for i in $(seq 0 $((mapping_count - 1))); do
    pattern=$(jq -r ".mappings[$i].pattern" "$MAPPING_FILE")
    affects_all_flag=$(jq -r ".mappings[$i].affects_all // false" "$MAPPING_FILE")

    # Check if pattern matches (glob pattern matching)
    # Convert glob pattern to regex:
    #   ** matches any path (including /)
    #   * matches any characters except /
    #   . is escaped
    pattern_regex=$(echo "$pattern" |
      sed 's|\.|\\\.|g' |
      sed 's|\*\*|__DOUBLE_STAR__|g' |
      sed 's|\*|[^/]*|g' |
      sed 's|__DOUBLE_STAR__|.*|g')

    # Match pattern against changed file
    if echo "$changed_file" | grep -qE "^$pattern_regex$"; then
      # If this pattern affects all tests, set flag
      if [ "$affects_all_flag" = "true" ]; then
        affects_all=true
      fi

      # Add associated tests
      test_list=$(jq -r ".mappings[$i].tests[]" "$MAPPING_FILE")
      while IFS= read -r test_file; do
        if [ -n "$test_file" ]; then
          tests_to_run["$test_file"]=1
        fi
      done <<< "$test_list"
    fi
  done
done <<< "$changed_files"

# If any change affects all tests, return empty (will run all tests)
if [ "$affects_all" = "true" ]; then
  exit 0
fi

# Output unique test files
if [ ${#tests_to_run[@]} -eq 0 ]; then
  # No specific tests matched, run all tests
  exit 0
fi

# Print space-separated list of test files
for test_file in "${!tests_to_run[@]}"; do
  echo -n "$test_file "
done

echo ""
