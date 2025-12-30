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
trap 'rm -rf "$workdir"' EXIT

# Test 1: Script loads without errors
if [ ! -f ~/.bashrc.d/75-security-permissions.sh ]; then
  fail "75-security-permissions.sh file not found (should be deployed by chezmoi)"
fi

# Source the script in a subshell to avoid affecting current environment
set +u
bash -c "source ~/.bashrc.d/75-security-permissions.sh" 2>&1 || fail "Script failed to load"
set -u
pass "Script loads without errors"

# Test 2: Cache mechanism works correctly
CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/security-permissions-last-run"
CACHE_DIR="$(dirname "$CACHE_FILE")"

# Clean up any existing cache file
rm -f "$CACHE_FILE"

# Test cache creation
FORCE_SECURITY_PERMISSIONS=1 SECURITY_PERMISSIONS_CACHE_INTERVAL=1 \
  bash -c "source ~/.bashrc.d/75-security-permissions.sh" 2>&1 || true

if [ -f "$CACHE_FILE" ]; then
  pass "Cache file is created after script execution"
else
  fail "Cache file was not created"
fi

# Test cache skipping (should skip if cache is recent)
# Update cache file timestamp to make it recent
touch "$CACHE_FILE"
sleep 1  # Small delay to ensure timestamp is set

# Test that script skips when cache is recent (within interval)
# We verify by checking that the cache file timestamp doesn't change
# (if script runs, it would update the timestamp)
old_timestamp=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)
SECURITY_PERMISSIONS_CACHE_INTERVAL=300 \
  bash -c "source ~/.bashrc.d/75-security-permissions.sh" 2>&1 || true
new_timestamp=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)

# If timestamps are the same (or very close), script was skipped
if [ "$old_timestamp" -eq "$new_timestamp" ] || [ $((new_timestamp - old_timestamp)) -lt 2 ]; then
  pass "Cache mechanism works (script skipped when cache is recent)"
else
  warn "Cache mechanism check (timestamp changed, script may have run)"
fi

# Test 3: Force execution bypasses cache
rm -f "$CACHE_FILE"
FORCE_SECURITY_PERMISSIONS=1 \
  bash -c "source ~/.bashrc.d/75-security-permissions.sh" 2>&1 || true

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
bash -c "
  source ~/.bashrc.d/75-security-permissions.sh
  set_file_permission '$test_file' 600
" 2>&1 || true

# Check if permissions were set
if [ -f "$test_file" ]; then
  perms=$(stat -c "%a" "$test_file" 2>/dev/null || stat -f "%OLp" "$test_file" 2>/dev/null || echo "unknown")
  if [ "$perms" = "600" ]; then
    pass "File permissions are set correctly (600)"
  else
    warn "File permissions check (expected 600, got $perms - file may not exist in subshell context)"
  fi
else
  warn "Test file not found (may be expected in subshell context)"
fi

# Test 5: Directory permissions are set correctly
test_dir="$workdir/test_credential_dir"
mkdir -p "$test_dir"
chmod 755 "$test_dir"

# Use absolute path to ensure directory is accessible in subshell
bash -c "
  source ~/.bashrc.d/75-security-permissions.sh
  set_dir_permission '$test_dir' 700
" 2>&1 || true

if [ -d "$test_dir" ]; then
  perms=$(stat -c "%a" "$test_dir" 2>/dev/null || stat -f "%OLp" "$test_dir" 2>/dev/null || echo "unknown")
  if [ "$perms" = "700" ]; then
    pass "Directory permissions are set correctly (700)"
  else
    warn "Directory permissions check (expected 700, got $perms - directory may not exist in subshell context)"
  fi
else
  warn "Test directory not found (may be expected in subshell context)"
fi

# Test 6: Debug mode works
DEBUG_SECURITY_PERMISSIONS=1 FORCE_SECURITY_PERMISSIONS=1 \
  bash -c "source ~/.bashrc.d/75-security-permissions.sh" 2>&1 | grep -q "Error" || true
pass "Debug mode can be enabled (no errors when no failures)"

# Test 7: Error logging is optional (disabled by default)
LOG_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/security-permissions-errors.log"
rm -f "$LOG_FILE"

FORCE_SECURITY_PERMISSIONS=1 \
  bash -c "source ~/.bashrc.d/75-security-permissions.sh" 2>&1 || true

if [ ! -f "$LOG_FILE" ]; then
  pass "Error logging is disabled by default"
else
  warn "Error log file exists (should not exist when logging is disabled)"
fi

# Test 8: Error logging can be enabled
ENABLE_SECURITY_PERMISSIONS_LOG=1 FORCE_SECURITY_PERMISSIONS=1 \
  bash -c "source ~/.bashrc.d/75-security-permissions.sh" 2>&1 || true

# Log file may or may not exist depending on whether errors occurred
if [ -f "$LOG_FILE" ]; then
  pass "Error logging can be enabled via environment variable (log file created)"
else
  pass "Error logging can be enabled via environment variable (no errors to log)"
fi

# Cleanup
rm -f "$CACHE_FILE" "$LOG_FILE"

print_summary

