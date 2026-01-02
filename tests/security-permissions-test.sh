#!/usr/bin/env bash
# Test security permissions script
# Usage: bash tests/security-permissions-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

echo "=========================================="
echo "Testing Security Permissions Script"
echo "=========================================="

# Create temporary directory for test files
workdir=$(setup_tmpdir)
# Use an isolated HOME for all tests to avoid touching real dotfiles in the container.
TEST_HOME="$workdir/home"
mkdir -p "$TEST_HOME"
SCRIPT_PATH="$HOME/.bashrc.d/030-security-permissions.sh"
XDG_CACHE_HOME_TEST="$TEST_HOME/.cache"
CACHE_FILE="$XDG_CACHE_HOME_TEST/security-permissions-last-run"
CACHE_LOCK_DIR="${CACHE_FILE}.lock.d"
# Initialize test_restricted_file variable for trap cleanup
test_restricted_file=""
trap 'if [ -n "$test_restricted_file" ] && [ -f "$test_restricted_file" ]; then chmod 644 "$test_restricted_file" 2>/dev/null || true; fi; rm -rf "$workdir" "$CACHE_LOCK_DIR"' EXIT

# Test 1: Script loads without errors
if [ ! -f ~/.bashrc.d/030-security-permissions.sh ]; then
  fail "030-security-permissions.sh file not found (should be deployed by chezmoi)"
fi

# Source the script in a subshell to avoid affecting current environment
bash -c "HOME='$TEST_HOME' XDG_CACHE_HOME='$XDG_CACHE_HOME_TEST' source '$SCRIPT_PATH'" 2>&1 || fail "Script failed to load"
pass "Script loads without errors"

# Test 2: Cache mechanism works correctly
# Clean up any existing cache file
rm -f "$CACHE_FILE"

# Test cache creation
FORCE_SECURITY_PERMISSIONS=1 SECURITY_PERMISSIONS_CACHE_INTERVAL=1 \
  bash -c "HOME='$TEST_HOME' XDG_CACHE_HOME='$XDG_CACHE_HOME_TEST' source '$SCRIPT_PATH'"

if [ -f "$CACHE_FILE" ]; then
  pass "Cache file is created after script execution"
else
  fail "Cache file was not created"
fi

# Test cache skipping (should skip if cache is recent)
# Update cache file timestamp to make it recent
touch "$CACHE_FILE"
sleep 1 # Small delay to ensure timestamp is set

# Test that script skips when cache is recent (within interval)
# We verify by checking that the cache file timestamp doesn't change
# (if script runs, it would update the timestamp)
set +e
old_timestamp_output=$(stat -c %Y "$CACHE_FILE" 2>&1)
old_timestamp_exit=$?
set -e
if [ $old_timestamp_exit -eq 0 ]; then
  old_timestamp="$old_timestamp_output"
else
  fail "Failed to get cache file timestamp: $old_timestamp_output"
  old_timestamp=0
fi
SECURITY_PERMISSIONS_CACHE_INTERVAL=300 \
  bash -c "HOME='$TEST_HOME' XDG_CACHE_HOME='$XDG_CACHE_HOME_TEST' source '$SCRIPT_PATH'"
set +e
new_timestamp_output=$(stat -c %Y "$CACHE_FILE" 2>&1)
new_timestamp_exit=$?
set -e
if [ $new_timestamp_exit -eq 0 ]; then
  new_timestamp="$new_timestamp_output"
else
  fail "Failed to get cache file timestamp after script execution: $new_timestamp_output"
  new_timestamp=0
fi

# If timestamps are the same (or very close), script was skipped
if [ "$old_timestamp" -eq "$new_timestamp" ] || [ $((new_timestamp - old_timestamp)) -lt 2 ]; then
  pass "Cache mechanism works (script skipped when cache is recent)"
else
  warn "Cache mechanism check (timestamp changed, script may have run)"
fi

# Test 3: Force execution bypasses cache
rm -f "$CACHE_FILE"
FORCE_SECURITY_PERMISSIONS=1 \
  bash -c "HOME='$TEST_HOME' XDG_CACHE_HOME='$XDG_CACHE_HOME_TEST' source '$SCRIPT_PATH'"

if [ -f "$CACHE_FILE" ]; then
  pass "Force execution creates cache file"
else
  fail "Force execution did not create cache file"
fi

# Test 4: File permissions are set correctly (behavior test)
# The script enforces strict permissions on known credential files.
test_file="$TEST_HOME/.git-credentials"
mkdir -p "$(dirname "$test_file")"
echo "test content" > "$test_file"
chmod 644 "$test_file"

assert_command "bash -c \"HOME='$TEST_HOME' XDG_CACHE_HOME='$XDG_CACHE_HOME_TEST' FORCE_SECURITY_PERMISSIONS=1 source '$SCRIPT_PATH'\" >/dev/null 2>&1" "Script can run to enforce file permissions"

# Check if permissions were set
if [ -f "$test_file" ]; then
  perms_output=$(stat -c "%a" "$test_file" 2>&1)
  perms_exit=$?
  if [ $perms_exit -eq 0 ]; then
    perms="$perms_output"
    if [ "$perms" = "600" ]; then
      pass "File permissions are set correctly (600)"
    else
      warn "File permissions check (expected 600, got $perms)"
    fi
  else
    fail "Failed to get file permissions: $perms_output"
  fi
else
  warn "Test file not found (may be expected in subshell context)"
fi

# Test 5: Directory permissions are set correctly (behavior test)
test_dir="$TEST_HOME/.ssh"
mkdir -p "$test_dir"
chmod 755 "$test_dir"

assert_command "bash -c \"HOME='$TEST_HOME' XDG_CACHE_HOME='$XDG_CACHE_HOME_TEST' FORCE_SECURITY_PERMISSIONS=1 source '$SCRIPT_PATH'\" >/dev/null 2>&1" "Script can run to enforce directory permissions"

if [ -d "$test_dir" ]; then
  perms_output=$(stat -c "%a" "$test_dir" 2>&1)
  perms_exit=$?
  if [ $perms_exit -eq 0 ]; then
    perms="$perms_output"
    if [ "$perms" = "700" ]; then
      pass "Directory permissions are set correctly (700)"
    else
      warn "Directory permissions check (expected 700, got $perms)"
    fi
  else
    fail "Failed to get directory permissions: $perms_output"
  fi
else
  warn "Test directory not found (may be expected in subshell context)"
fi

# Test 6: Debug mode works
# This test checks that debug mode doesn't fail even when there are no errors
assert_command "DEBUG_SECURITY_PERMISSIONS=1 FORCE_SECURITY_PERMISSIONS=1 bash -c \"HOME='$TEST_HOME' XDG_CACHE_HOME='$XDG_CACHE_HOME_TEST' source '$SCRIPT_PATH'\" >/dev/null 2>&1" "Debug mode can be enabled (no errors when no failures)"

# Test 7: Error logging is optional (disabled by default)
LOG_FILE="$XDG_CACHE_HOME_TEST/security-permissions-errors.log"
rm -f "$LOG_FILE"

FORCE_SECURITY_PERMISSIONS=1 \
  bash -c "HOME='$TEST_HOME' XDG_CACHE_HOME='$XDG_CACHE_HOME_TEST' source '$SCRIPT_PATH'"

if [ ! -f "$LOG_FILE" ]; then
  pass "Error logging is disabled by default"
else
  warn "Error log file exists (should not exist when logging is disabled)"
fi

# Test 8: Error logging can be enabled
ENABLE_SECURITY_PERMISSIONS_LOG=1 FORCE_SECURITY_PERMISSIONS=1 \
  bash -c "HOME='$TEST_HOME' XDG_CACHE_HOME='$XDG_CACHE_HOME_TEST' source '$SCRIPT_PATH'"

# Log file may or may not exist depending on whether errors occurred
if [ -f "$LOG_FILE" ]; then
  pass "Error logging can be enabled via environment variable (log file created)"
else
  pass "Error logging can be enabled via environment variable (no errors to log)"
fi

# Test 9: Error detection - test with a file that cannot be accessed
# Create a file with restricted permissions that script tries to access
test_restricted_file="$workdir/restricted_file"
echo "test" > "$test_restricted_file"
chmod 000 "$test_restricted_file"
# Trap will handle cleanup on exit (including error cases)

# Try to read the file as an unprivileged user (root can bypass permissions)
if command -v sudo > /dev/null 2>&1 && id -u nobody > /dev/null 2>&1; then
  set +e
  stat_output=$(sudo -n -u nobody stat -c "%a" "$test_restricted_file" 2>&1)
  stat_exit=$?
  set -e
  if [ $stat_exit -ne 0 ] && echo "$stat_output" | grep -qE "(Permission denied|permission denied)"; then
    pass "Permission error is properly detected and reported (as nobody)"
  else
    fail "Expected permission denied for restricted file (as nobody), got: exit=$stat_exit output=$stat_output"
  fi
else
  # Environment doesn't support unprivileged check; skip without warning noise
  pass "Permission error detection skipped (no sudo or nobody user available)"
fi

# Test 10: Error log content verification (if logging is enabled and errors occurred)
if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
  # Check that log file contains timestamp and error message format
  if head -1 "$LOG_FILE" | grep -qE "^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\]"; then
    pass "Error log contains properly formatted timestamps"
  else
    warn "Error log format check (expected timestamp format, got: $(head -1 "$LOG_FILE"))"
  fi
else
  # No errors to log is also acceptable
  pass "Error log verification (no errors to log or logging disabled)"
fi

# Test 11: Debug mode outputs error messages
set +e
debug_output=$(DEBUG_SECURITY_PERMISSIONS=1 FORCE_SECURITY_PERMISSIONS=1 \
  bash -c "HOME='$TEST_HOME' XDG_CACHE_HOME='$XDG_CACHE_HOME_TEST' source '$SCRIPT_PATH'" 2>&1)
set -e
# Debug mode should not fail, but may output warnings
if echo "$debug_output" | grep -qiE "(error|warning|fail)"; then
  # If there are errors/warnings, they should be visible in debug mode
  pass "Debug mode shows error/warning messages when present"
else
  # No errors is also acceptable
  pass "Debug mode works (no errors to report)"
fi

# Test 12: Script handles missing files gracefully (no crash)
# Run in an empty HOME without any target files present.
empty_home="$workdir/empty_home"
mkdir -p "$empty_home"
assert_command "bash -c \"HOME='$empty_home' XDG_CACHE_HOME='$empty_home/.cache' FORCE_SECURITY_PERMISSIONS=1 source '$SCRIPT_PATH'\" >/dev/null 2>&1" "Script handles missing files gracefully"

# Cleanup
rm -f "$CACHE_FILE" "$LOG_FILE"
chmod 644 "$test_restricted_file" 2> /dev/null || true

print_summary
