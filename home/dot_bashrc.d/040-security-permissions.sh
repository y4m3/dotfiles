#!/usr/bin/env bash
# 040-security-permissions.sh — Security: strict file permissions for credentials
# Category: 0xx (Core) (Core functionality)
# Automatically sets strict permissions on credential files and directories
# See: docs/tools/security.md

# Run in a subshell to avoid polluting the caller's shell (variables/functions) when sourced from bashrc.d.
(
  # Performance optimization: skip if run recently
  CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/security-permissions-last-run"
  CACHE_INTERVAL="${SECURITY_PERMISSIONS_CACHE_INTERVAL:-300}" # 5 minutes default
  CACHE_LOCK_DIR="${CACHE_FILE}.lock.d"

  # Helper function: log error (optional)
  LOG_ROTATION_CHECKED=0
  log_error() {
    if [ "${ENABLE_SECURITY_PERMISSIONS_LOG:-0}" -eq 1 ]; then
      local log_file="${XDG_CACHE_HOME:-$HOME/.cache}/security-permissions-errors.log"
      mkdir -p "$(dirname "$log_file")" > /dev/null 2>&1 || {
        [ "${DEBUG_SECURITY_PERMISSIONS:-0}" -eq 1 ] && echo "Warning: Failed to create log directory for $log_file" >&2
        # Early return inside log_error (do not fail interactive shells)
        return 0
      }
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$log_file" 2> /dev/null || {
        [ "${DEBUG_SECURITY_PERMISSIONS:-0}" -eq 1 ] && echo "Warning: Failed to write to log file $log_file" >&2
        # Early return inside log_error (do not fail interactive shells)
        return 0
      }

      # Simple log rotation (keep last 5 files, max 10KB each)
      # Only check once per script execution to avoid performance issues
      if [ "$LOG_ROTATION_CHECKED" -eq 0 ] && [ -f "$log_file" ]; then
        LOG_ROTATION_CHECKED=1
        local file_size
        # Ubuntu 24.04 uses Linux stat format
        if stat_output=$(stat -c %s "$log_file" 2>&1); then
          file_size="$stat_output"
        else
          # Avoid calling log_error() recursively from within log_error().
          # If debug is enabled, print a warning to stderr for observability.
          if [ "${DEBUG_SECURITY_PERMISSIONS:-0}" -eq 1 ]; then
            echo "Warning: Failed to read log file size: $stat_output" >&2
          fi
          file_size=0
        fi
        if [ "$file_size" -gt 10240 ]; then
          for ((i = 4; i >= 1; i--)); do
            if [ -f "${log_file}.$i" ]; then
              mv "${log_file}.$i" "${log_file}.$((i + 1))" > /dev/null 2>&1 || true
            fi
          done
          mv "$log_file" "${log_file}.1" > /dev/null 2>&1 || true
        fi
      fi
    fi
  }

  # Helper function: set file permission
  set_file_permission() {
    local file="$1"
    local perm="${2:-600}"
    if [ -f "$file" ]; then
      if ! chmod "$perm" "$file" > /dev/null 2>&1; then
        log_error "Failed to set permissions on $file"
        if [ "${DEBUG_SECURITY_PERMISSIONS:-0}" -eq 1 ]; then
          echo "Error setting permissions on $file" >&2
        fi
      fi
    fi
  }

  # Helper function: set directory permission
  set_dir_permission() {
    local dir="$1"
    local perm="${2:-700}"
    if [ -d "$dir" ]; then
      if ! chmod "$perm" "$dir" > /dev/null 2>&1; then
        log_error "Failed to set permissions on $dir"
        if [ "${DEBUG_SECURITY_PERMISSIONS:-0}" -eq 1 ]; then
          echo "Error setting permissions on $dir" >&2
        fi
      fi
    fi
  }

  # Simple lock mechanism to avoid race conditions on the cache file
  acquire_cache_lock() {
    # Try to acquire the lock a limited number of times to avoid hanging indefinitely
    local i
    local last_error=""
    local lock_output=""
    local lock_exit_code=0
    for i in 1 2 3 4 5; do
      # mkdir is silent on success; capture stderr for debugging/errors
      lock_output=$(mkdir "$CACHE_LOCK_DIR" 2>&1)
      lock_exit_code=$?
      if [ $lock_exit_code -eq 0 ]; then
        return 0
      fi
      # Only capture error messages
      if [ $lock_exit_code -ne 0 ]; then
        last_error="$lock_output"
      fi
      sleep 0.1
    done
    # If we can't acquire the lock, check if it's a serious error (not just lock contention)
    # Lock contention (directory exists) is normal, but permission errors are serious
    if echo "$last_error" | grep -qE "(Permission denied|permission denied|Not a directory)"; then
      log_error "Failed to acquire cache lock due to permission error: $last_error"
      if [ "${DEBUG_SECURITY_PERMISSIONS:-0}" -eq 1 ]; then
        echo "Error: Failed to acquire cache lock due to permission error" >&2
        echo "$last_error" >&2
      fi
    fi
    # If we can't acquire the lock, proceed without caching guarantees
    return 1
  }

  release_cache_lock() {
    if [ -d "$CACHE_LOCK_DIR" ]; then
      rmdir "$CACHE_LOCK_DIR" || {
        log_error "Failed to remove cache lock directory: $CACHE_LOCK_DIR"
        if [ "${DEBUG_SECURITY_PERMISSIONS:-0}" -eq 1 ]; then
          echo "Warning: Failed to remove cache lock directory: $CACHE_LOCK_DIR" >&2
        fi
      }
    fi
  }

  # Evaluate cache; if recent, skip the main execution. (Functions are defined above.)
  should_skip_main=0
  if acquire_cache_lock; then
    if [ -z "${FORCE_SECURITY_PERMISSIONS:-}" ] && [ -f "$CACHE_FILE" ]; then
      # Check if cache is still valid
      # Ubuntu 24.04 uses Linux stat format
      if stat_output=$(stat -c %Y "$CACHE_FILE" 2>&1); then
        last_run="$stat_output"
      else
        # Check if it's a permission error (serious)
        if echo "$stat_output" | grep -qE "(Permission denied|permission denied)"; then
          log_error "Failed to read cache file timestamp (permission error): $stat_output"
          if [ "${DEBUG_SECURITY_PERMISSIONS:-0}" -eq 1 ]; then
            echo "Warning: Permission error reading cache file" >&2
          fi
        fi
        last_run=0
      fi
      current_time=$(date +%s)
      if [ $((current_time - last_run)) -lt "$CACHE_INTERVAL" ]; then
        should_skip_main=1
      fi
    fi

    # Create/update cache file while holding the lock to prevent race conditions
    if [ "$should_skip_main" -eq 0 ]; then
      mkdir -p "$(dirname "$CACHE_FILE")" > /dev/null 2>&1 || {
        log_error "Failed to create cache directory: $(dirname "$CACHE_FILE")"
        [ "${DEBUG_SECURITY_PERMISSIONS:-0}" -eq 1 ] && echo "Warning: Failed to create cache directory" >&2
      }
      touch "$CACHE_FILE" > /dev/null 2>&1 || {
        log_error "Failed to touch cache file: $CACHE_FILE"
        [ "${DEBUG_SECURITY_PERMISSIONS:-0}" -eq 1 ] && echo "Warning: Failed to touch cache file" >&2
      }
    fi
    release_cache_lock
  else
    # Fallback: if lock cannot be acquired, still ensure cache directory exists
    # and proceed with execution (better to run twice than skip security checks)
    # Avoid unnecessary timestamp updates if another process recently refreshed the cache
    mkdir -p "$(dirname "$CACHE_FILE")" > /dev/null 2>&1 || {
      log_error "Failed to create cache directory: $(dirname "$CACHE_FILE")"
      [ "${DEBUG_SECURITY_PERMISSIONS:-0}" -eq 1 ] && echo "Warning: Failed to create cache directory" >&2
    }
    if [ -f "$CACHE_FILE" ]; then
      # Ubuntu 24.04 uses Linux stat format
      if stat_output=$(stat -c %Y "$CACHE_FILE" 2>&1); then
        cache_mtime="$stat_output"
      else
        # Check if it's a permission error (serious)
        if echo "$stat_output" | grep -qE "(Permission denied|permission denied)"; then
          log_error "Failed to read cache file timestamp (permission error): $stat_output"
          if [ "${DEBUG_SECURITY_PERMISSIONS:-0}" -eq 1 ]; then
            echo "Warning: Permission error reading cache file" >&2
          fi
        fi
        cache_mtime=0
      fi
      current_time=$(date +%s)
      if [ $((current_time - cache_mtime)) -lt "$CACHE_INTERVAL" ]; then
        should_skip_main=1
      elif [ $((current_time - cache_mtime)) -ge "$CACHE_INTERVAL" ]; then
        touch "$CACHE_FILE" > /dev/null 2>&1 || {
          log_error "Failed to touch cache file: $CACHE_FILE"
          [ "${DEBUG_SECURITY_PERMISSIONS:-0}" -eq 1 ] && echo "Warning: Failed to touch cache file" >&2
        }
      fi
    else
      touch "$CACHE_FILE" > /dev/null 2>&1 || {
        log_error "Failed to touch cache file: $CACHE_FILE"
        [ "${DEBUG_SECURITY_PERMISSIONS:-0}" -eq 1 ] && echo "Warning: Failed to touch cache file" >&2
      }
    fi
  fi

  if [ "$should_skip_main" -eq 1 ]; then
    exit 0
  fi

  # GitHub CLI
  set_dir_permission "$HOME/.config/gh" 700
  set_file_permission "$HOME/.config/gh/hosts.yml" 600

  # SSH
  set_dir_permission "$HOME/.ssh" 700
  for key_file in "$HOME/.ssh"/id_rsa "$HOME/.ssh"/id_ed25519 "$HOME/.ssh"/id_ecdsa "$HOME/.ssh"/id_dsa; do
    set_file_permission "$key_file" 600
  done
  set_file_permission "$HOME/.ssh/config" 600
  set_file_permission "$HOME/.ssh/authorized_keys" 600
  # known_hosts can remain 644 (readable by group/others is acceptable)
  # Public keys (*.pub) can remain 644

  # Git credentials
  set_file_permission "$HOME/.git-credentials" 600

  # npm/yarn
  set_file_permission "$HOME/.npmrc" 600

  # Docker
  set_dir_permission "$HOME/.docker" 700
  set_file_permission "$HOME/.docker/config.json" 600

  # Python
  set_file_permission "$HOME/.pypirc" 600
  set_file_permission "$HOME/.pip/pip.conf" 600

  # Rust
  set_dir_permission "$HOME/.cargo" 700
  set_file_permission "$HOME/.cargo/credentials" 600
  set_file_permission "$HOME/.cargo/credentials.toml" 600

  # GPG
  set_dir_permission "$HOME/.gnupg" 700
  for gpg_file in "$HOME/.gnupg"/secring.gpg "$HOME/.gnupg"/private-keys-v1.d; do
    if [ -e "$gpg_file" ]; then
      if [ -d "$gpg_file" ]; then
        set_dir_permission "$gpg_file" 700
      else
        set_file_permission "$gpg_file" 600
      fi
    fi
  done

  # Always return success for sourcing contexts; this is a best-effort hardening script.
  true
) # end subshell

_security_permissions_exit=$?
if [ "${BASH_SOURCE[0]:-}" != "${0:-}" ]; then
  # Note: In a sourced file, returning the subshell exit code without leaving *any*
  # temporary variable is impractical in Bash. We keep a single, uniquely-named variable.
  return "$_security_permissions_exit"
fi
exit "$_security_permissions_exit"
