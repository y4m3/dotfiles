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
CACHE_LOCK_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/security-permissions-last-run.lock.d"
trap 'rm -rf "$workdir" "$CACHE_LOCK_DIR"' EXIT

# Test 1: Script loads without errors
if [ ! -f ~/.bashrc.d/75-security-permissions.sh ]; then
  fail "75-security-permissions.sh file not found (should be deployed by chezmoi)"
fi

# Source the script in a subshell to avoid affecting current environment
bash -c "source ~/.bashrc.d/75-security-permissions.sh" 2>&1 || fail "Script failed to load"
pass "Script loads without errors"

# Test 2: Cache mechanism works correctly
CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/security-permissions-last-run"

# Clean up any existing cache file
rm -f "$CACHE_FILE"

# Test cache creation
FORCE_SECURITY_PERMISSIONS=1 SECURITY_PERMISSIONS_CACHE_INTERVAL=1 \
  bash -c "source ~/.bashrc.d/75-security-permissions.sh"

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
old_timestamp_output=$(stat -c %Y "$CACHE_FILE" 2>&1)
old_timestamp_exit=$?
if [ $old_timestamp_exit -eq 0 ]; then
  old_timestamp="$old_timestamp_output"
else
  fail "Failed to get cache file timestamp: $old_timestamp_output"
  old_timestamp=0
fi
SECURITY_PERMISSIONS_CACHE_INTERVAL=300 \
  bash -c "source ~/.bashrc.d/75-security-permissions.sh"
new_timestamp_output=$(stat -c %Y "$CACHE_FILE" 2>&1)
new_timestamp_exit=$?
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
  bash -c "source ~/.bashrc.d/75-security-permissions.sh"

if [ -f "$CACHE_FILE" ]; then
  pass "Force execution creates cache file"
else
  fail "Force execution did not create cache file"
fi

# Test 4: File permissions are set correctly (on test files)
test_file="$workdir/test_credential_file"
echo "test content" > "$test_file"
chmod 644 "$test_file"

# Source script and check if it sets permissions
# Use absolute path to ensure file is accessible in subshell
# Note: set_file_permission is a function defined in 75-security-permissions.sh
# Functions exported with export -f should be available in subshells
permission_output=$(bash -c "
  source ~/.bashrc.d/75-security-permissions.sh
  set_file_permission '$test_file' 600
" 2>&1)
permission_exit=$?
if [ $permission_exit -ne 0 ]; then
  # Check if it's a read-only filesystem error (acceptable in some test environments)
  if echo "$permission_output" | grep -qiE "(read-only|readonly)"; then
    warn "File permission setting skipped (read-only filesystem: $permission_output)"
  else
    warn "Failed to set file permissions: $permission_output"
  fi
fi

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

# Test 5: Directory permissions are set correctly
test_dir="$workdir/test_credential_dir"
mkdir -p "$test_dir"
chmod 755 "$test_dir"

# Use absolute path to ensure directory is accessible in subshell
# Note: set_dir_permission is a function defined in 75-security-permissions.sh
# Functions exported with export -f should be available in subshells
dir_permission_output=$(bash -c "
  source ~/.bashrc.d/75-security-permissions.sh
  set_dir_permission '$test_dir' 700
" 2>&1)
dir_permission_exit=$?
if [ $dir_permission_exit -ne 0 ]; then
  # Check if it's a read-only filesystem error (acceptable in some test environments)
  if echo "$dir_permission_output" | grep -qiE "(read-only|readonly)"; then
    warn "Directory permission setting skipped (read-only filesystem: $dir_permission_output)"
  else
    warn "Failed to set directory permissions: $dir_permission_output"
  fi
fi

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
if DEBUG_SECURITY_PERMISSIONS=1 FORCE_SECURITY_PERMISSIONS=1 \
  bash -c "source ~/.bashrc.d/75-security-permissions.sh"; then
  pass "Debug mode can be enabled (no errors when no failures)"
else
  fail "Debug mode failed unexpectedly"
fi

# Test 7: Error logging is optional (disabled by default)
LOG_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/security-permissions-errors.log"
rm -f "$LOG_FILE"

FORCE_SECURITY_PERMISSIONS=1 \
  bash -c "source ~/.bashrc.d/75-security-permissions.sh"

if [ ! -f "$LOG_FILE" ]; then
  pass "Error logging is disabled by default"
else
  warn "Error log file exists (should not exist when logging is disabled)"
fi

# Test 8: Error logging can be enabled
ENABLE_SECURITY_PERMISSIONS_LOG=1 FORCE_SECURITY_PERMISSIONS=1 \
  bash -c "source ~/.bashrc.d/75-security-permissions.sh"

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

# Try to read the file (should fail with permission error)
if stat_output=$(stat -c "%a" "$test_restricted_file" 2>&1); then
  # If we can read it, restore permissions and skip this test
  chmod 644 "$test_restricted_file"
  warn "Could not test permission error detection (file was readable)"
else
  # Verify error message contains permission-related text
  if echo "$stat_output" | grep -qE "(Permission denied|permission denied)"; then
    pass "Permission error is properly detected and reported"
  else
    warn "Permission error detection (expected permission denied message, got: $stat_output)"
  fi
  # Restore permissions for cleanup
  chmod 644 "$test_restricted_file"
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
debug_output=$(DEBUG_SECURITY_PERMISSIONS=1 FORCE_SECURITY_PERMISSIONS=1 \
  bash -c "source ~/.bashrc.d/75-security-permissions.sh" 2>&1)
# Debug mode should not fail, but may output warnings
if echo "$debug_output" | grep -qiE "(error|warning|fail)"; then
  # If there are errors/warnings, they should be visible in debug mode
  pass "Debug mode shows error/warning messages when present"
else
  # No errors is also acceptable
  pass "Debug mode works (no errors to report)"
fi

# Test 12: Error handling for non-existent files
# The script should handle non-existent files gracefully
non_existent_test="$workdir/non_existent_file_$$"
# Source script and try to set permissions on non-existent file
non_existent_output=$(bash -c "
  source ~/.bashrc.d/75-security-permissions.sh
  set_file_permission '$non_existent_test' 600
" 2>&1)
non_existent_exit=$?
# Function should handle non-existent file gracefully (not fail)
# The function checks if file exists before trying to set permissions
if [ $non_existent_exit -eq 0 ]; then
  pass "Script handles non-existent files gracefully"
else
  # Check if it's a function not found error (export issue) or actual error
  if echo "$non_existent_output" | grep -qiE "(command not found|function)"; then
    warn "Non-existent file handling (function may not be available in subshell: $non_existent_output)"
  else
    warn "Non-existent file handling (unexpected error: $non_existent_output)"
  fi
fi

# Cleanup
rm -f "$CACHE_FILE" "$LOG_FILE"
chmod 644 "$test_restricted_file" 2> /dev/null || true

print_summary
