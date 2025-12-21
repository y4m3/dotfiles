#!/usr/bin/env bash
# Common test helper functions
# Source this file in test scripts: source tests/lib/helpers.sh

set -euo pipefail

# Color codes for test output (disabled when not a TTY)
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  NC='\033[0m' # No Color
else
  RED=''
  GREEN=''
  YELLOW=''
  NC=''
fi

# Global test counters
TEST_PASS=0
TEST_FAIL=0

# fail: Print error message and increment counter
# Usage: fail "Error message"
fail() {
  echo -e "${RED}FAIL${NC}: $*" >&2
  TEST_FAIL=$((TEST_FAIL + 1))
}

# pass: Print success message
# Usage: pass "Success message"
pass() {
  echo -e "${GREEN}PASS${NC}: $*"
  TEST_PASS=$((TEST_PASS + 1))
}

# warn: Print warning message (non-fatal)
# Usage: warn "Warning message"
warn() {
  echo -e "${YELLOW}WARN${NC}: $*" >&2
}

# assert_command: Assert that a command succeeds
# Usage: assert_command "command to run" "description"
assert_command() {
  local cmd="$1"
  local desc="${2:-$cmd}"

  if eval "$cmd" &>/dev/null; then
    pass "$desc"
  else
    fail "$desc (command failed: $cmd)"
  fi
}

# assert_file_exists: Assert that a file exists
# Usage: assert_file_exists "/path/to/file" "description"
assert_file_exists() {
  local file="$1"
  local desc="${2:-File exists: $file}"

  if [ -f "$file" ]; then
    pass "$desc"
  else
    fail "$desc (file not found: $file)"
  fi
}

# assert_executable: Assert that a command is in PATH
# Usage: assert_executable "rustc" "Rust compiler installed"
assert_executable() {
  local cmd="$1"
  local desc="${2:-$cmd is executable}"

  if command -v "$cmd" >/dev/null 2>&1; then
    pass "$desc"
  else
    fail "$desc (command not found: $cmd)"
  fi
}

# assert_string_contains: Assert that output contains a string
# Usage: assert_string_contains "actual output" "expected substring" "description"
assert_string_contains() {
  local actual="$1"
  local expected="$2"
  local desc="${3:-Output contains \"$expected\"}"

  if echo "$actual" | grep -qF "$expected"; then
    pass "$desc"
  else
    fail "$desc (expected: '$expected', actual: '$actual')"
  fi
}

# print_summary: Print test summary
# Usage: print_summary
print_summary() {
  local total=$((TEST_PASS + TEST_FAIL))
  echo ""
  echo "================================"
  echo "Test Summary:"
  echo "  Passed: ${GREEN}$TEST_PASS${NC}"
  if [ $TEST_FAIL -gt 0 ]; then
    echo "  Failed: ${RED}$TEST_FAIL${NC}"
  else
    echo "  Failed: ${GREEN}0${NC}"
  fi
  echo "  Total:  $total"
  echo "================================"

  if [ $TEST_FAIL -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
  else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
  fi
}

# Create temporary directory with cleanup trap
# Usage: tmpdir=$(setup_tmpdir)
setup_tmpdir() {
  local tmpdir
  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT
  echo "$tmpdir"
}

export RED GREEN YELLOW NC TEST_PASS TEST_FAIL
