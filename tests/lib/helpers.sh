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
TEST_WARN=0

# Array to store warning messages for summary display
declare -a TEST_WARN_MESSAGES=()

# Test log file (if TEST_LOG_FILE is set, all output will be logged there)
TEST_LOG_FILE="${TEST_LOG_FILE:-}"

# fail: Print error message and increment counter
# Usage: fail "Error message"
fail() {
  echo -e "${RED}FAIL${NC}: $*" >&2
  TEST_FAIL=$((TEST_FAIL + 1))
  # Log to file if TEST_LOG_FILE is set
  if [ -n "$TEST_LOG_FILE" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] FAIL: $*" >> "$TEST_LOG_FILE" 2>&1 || true
  fi
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
  TEST_WARN=$((TEST_WARN + 1))
  # Store warning message for summary display
  TEST_WARN_MESSAGES+=("$*")
  # Log to file if TEST_LOG_FILE is set
  if [ -n "$TEST_LOG_FILE" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARN: $*" >> "$TEST_LOG_FILE" 2>&1 || true
  fi
}

# assert_command: Assert that a command succeeds
# Usage: assert_command "command to run" "description" [quiet]
#   quiet: if "true", suppress output in error message (default: false)
assert_command() {
  local cmd="$1"
  local desc="${2:-$cmd}"
  local quiet="${3:-false}"

  local output
  local exit_code
  output=$(eval "$cmd" 2>&1)
  exit_code=$?

  if [ $exit_code -eq 0 ]; then
    pass "$desc"
  else
    if [ "$quiet" = "true" ]; then
      fail "$desc (command failed: $cmd, exit code: $exit_code)"
    else
      # Truncate output if too long (more than 500 characters)
      local truncated_output
      if [ ${#output} -gt 500 ]; then
        truncated_output="${output:0:500}... (truncated, ${#output} chars total)"
      else
        truncated_output="$output"
      fi
      fail "$desc (command failed: $cmd, exit code: $exit_code, output: $truncated_output)"
    fi
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

  if command -v "$cmd" > /dev/null 2>&1; then
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
    # Truncate actual output if too long
    local truncated_actual
    if [ ${#actual} -gt 200 ]; then
      truncated_actual="${actual:0:200}... (truncated, ${#actual} chars total)"
    else
      truncated_actual="$actual"
    fi
    fail "$desc (expected: '$expected', actual: '$truncated_actual')"
  fi
}

# assert_command_fails: Assert that a command fails (non-zero exit code)
# Usage: assert_command_fails "command to run" "description" [expected_exit_code]
#   expected_exit_code: optional, specific exit code to expect (default: any non-zero)
assert_command_fails() {
  local cmd="$1"
  local desc="${2:-$cmd should fail}"
  local expected_exit="${3:-}"

  local output
  local exit_code
  output=$(eval "$cmd" 2>&1)
  exit_code=$?

  if [ $exit_code -eq 0 ]; then
    fail "$desc (command succeeded but should have failed: $cmd)"
  elif [ -n "$expected_exit" ] && [ $exit_code -ne "$expected_exit" ]; then
    fail "$desc (command failed with exit code $exit_code, expected $expected_exit: $cmd)"
  else
    pass "$desc (command failed as expected, exit code: $exit_code)"
  fi
}

# assert_exit_code: Assert that a command returns a specific exit code
# Usage: assert_exit_code "command to run" "expected_exit_code" "description"
assert_exit_code() {
  local cmd="$1"
  local expected_exit="$2"
  local desc="${3:-Command should exit with code $expected_exit}"

  local output
  local exit_code
  output=$(eval "$cmd" 2>&1)
  exit_code=$?

  if [ $exit_code -eq "$expected_exit" ]; then
    pass "$desc"
  else
    # Truncate output if too long
    local truncated_output
    if [ ${#output} -gt 200 ]; then
      truncated_output="${output:0:200}... (truncated, ${#output} chars total)"
    else
      truncated_output="$output"
    fi
    fail "$desc (expected exit code: $expected_exit, actual: $exit_code, output: $truncated_output)"
  fi
}

# assert_output_contains: Assert that command output contains a string
# Usage: assert_output_contains "command to run" "expected substring" "description"
assert_output_contains() {
  local cmd="$1"
  local expected="$2"
  local desc="${3:-Command output should contain \"$expected\"}"

  local output
  local exit_code
  output=$(eval "$cmd" 2>&1)
  exit_code=$?

  if echo "$output" | grep -qF "$expected"; then
    pass "$desc"
  else
    # Truncate output if too long
    local truncated_output
    if [ ${#output} -gt 200 ]; then
      truncated_output="${output:0:200}... (truncated, ${#output} chars total)"
    else
      truncated_output="$output"
    fi
    fail "$desc (expected output to contain: '$expected', actual: '$truncated_output', exit code: $exit_code)"
  fi
}

# print_summary: Print test summary
# Usage: print_summary
# Determines success based on absence of FAIL and WARN
print_summary() {
  local total=$((TEST_PASS + TEST_FAIL))
  local test_script_name="${0:-unknown}"
  local summary_msg=""

  echo ""
  echo "================================"
  echo "Test Summary:"
  echo "  Passed: ${GREEN}$TEST_PASS${NC}"
  if [ $TEST_FAIL -gt 0 ]; then
    echo "  Failed: ${RED}$TEST_FAIL${NC}"
  else
    echo "  Failed: ${GREEN}0${NC}"
  fi
  if [ $TEST_WARN -gt 0 ]; then
    echo "  Warnings: ${YELLOW}$TEST_WARN${NC}"
  else
    echo "  Warnings: ${GREEN}0${NC}"
  fi
  echo "  Total:  $total"
  echo "================================"

  # Log summary to file if TEST_LOG_FILE is set
  if [ -n "$TEST_LOG_FILE" ]; then
    {
      echo ""
      echo "================================"
      echo "Test Summary for $test_script_name:"
      echo "  Passed: $TEST_PASS"
      echo "  Failed: $TEST_FAIL"
      echo "  Warnings: $TEST_WARN"
      echo "  Total: $total"
      echo "================================"
    } >> "$TEST_LOG_FILE" 2>&1 || true
  fi

  # Test passes only if there are no FAIL (WARN is non-fatal)
  if [ $TEST_FAIL -eq 0 ]; then
    if [ $TEST_WARN -eq 0 ]; then
      summary_msg="${GREEN}All tests passed! (No FAIL, No WARN)${NC}"
      echo -e "$summary_msg"
      if [ -n "$TEST_LOG_FILE" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $test_script_name: All tests passed! (No FAIL, No WARN)" >> "$TEST_LOG_FILE" 2>&1 || true
      fi
    else
      # TEST_WARN > 0 but TEST_FAIL == 0
      summary_msg="${YELLOW}Tests passed with warnings! (WARN: $TEST_WARN)${NC}"
      echo -e "$summary_msg"
      echo ""
      echo "${YELLOW}Warning Details:${NC}"
      local i=1
      for warn_msg in "${TEST_WARN_MESSAGES[@]}"; do
        echo "  ${YELLOW}[$i]${NC} $warn_msg"
        i=$((i + 1))
      done
      if [ -n "$TEST_LOG_FILE" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $test_script_name: Tests passed with warnings! (WARN: $TEST_WARN)" >> "$TEST_LOG_FILE" 2>&1 || true
        echo "" >> "$TEST_LOG_FILE" 2>&1 || true
        echo "Warning Details:" >> "$TEST_LOG_FILE" 2>&1 || true
        i=1
        for warn_msg in "${TEST_WARN_MESSAGES[@]}"; do
          echo "  [$i] $warn_msg" >> "$TEST_LOG_FILE" 2>&1 || true
          i=$((i + 1))
        done
      fi
    fi
    exit 0
  else
    # TEST_FAIL > 0
    summary_msg="${RED}Some tests failed! (FAIL: $TEST_FAIL)${NC}"
    echo -e "$summary_msg"
    if [ $TEST_WARN -gt 0 ]; then
      echo ""
      echo "${YELLOW}Warning Details (also occurred):${NC}"
      local i=1
      for warn_msg in "${TEST_WARN_MESSAGES[@]}"; do
        echo "  ${YELLOW}[$i]${NC} $warn_msg"
        i=$((i + 1))
      done
    fi
    if [ -n "$TEST_LOG_FILE" ]; then
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] $test_script_name: Some tests failed! (FAIL: $TEST_FAIL)" >> "$TEST_LOG_FILE" 2>&1 || true
      if [ $TEST_WARN -gt 0 ]; then
        echo "" >> "$TEST_LOG_FILE" 2>&1 || true
        echo "Warning Details (also occurred):" >> "$TEST_LOG_FILE" 2>&1 || true
        i=1
        for warn_msg in "${TEST_WARN_MESSAGES[@]}"; do
          echo "  [$i] $warn_msg" >> "$TEST_LOG_FILE" 2>&1 || true
          i=$((i + 1))
        done
      fi
    fi
    exit 1
  fi
}

# Create temporary directory with cleanup trap
# Usage: tmpdir=$(setup_tmpdir)
setup_tmpdir() {
  local tmpdir
  tmpdir=$(mktemp -d)
  echo "$tmpdir"
}

export RED GREEN YELLOW NC TEST_PASS TEST_FAIL TEST_WARN TEST_LOG_FILE
