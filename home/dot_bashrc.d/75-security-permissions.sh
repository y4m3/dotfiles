#!/usr/bin/env bash
# 75-security-permissions.sh — Security: strict file permissions for credentials
# Automatically sets strict permissions on credential files and directories

# Performance optimization: skip if run recently
CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/security-permissions-last-run"
CACHE_INTERVAL="${SECURITY_PERMISSIONS_CACHE_INTERVAL:-300}"  # 5 minutes default
CACHE_LOCK_DIR="${CACHE_FILE}.lock.d"

# Simple lock mechanism to avoid race conditions on the cache file
acquire_cache_lock() {
  # Try to acquire the lock a limited number of times to avoid hanging indefinitely
  local i
  for i in 1 2 3 4 5; do
    if mkdir "$CACHE_LOCK_DIR" 2>/dev/null; then
      return 0
    fi
    sleep 0.1
  done
  # If we can't acquire the lock, proceed without caching guarantees
  return 1
}

release_cache_lock() {
  rmdir "$CACHE_LOCK_DIR" 2>/dev/null || true
}

# Acquire lock and check cache
if acquire_cache_lock; then
  if [ -z "${FORCE_SECURITY_PERMISSIONS:-}" ] && [ -f "$CACHE_FILE" ]; then
    # Check if cache is still valid
    if command -v stat >/dev/null 2>&1; then
      # Try Linux format first, then macOS format
      last_run=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)
    else
      # Fallback to date command (BSD)
      last_run=$(date -r "$CACHE_FILE" +%s 2>/dev/null || echo 0)
    fi
    current_time=$(date +%s)
    if [ $((current_time - last_run)) -lt "$CACHE_INTERVAL" ]; then
      release_cache_lock
      return 0  # Skip execution
    fi
  fi

  # Create/update cache file while holding the lock to prevent race conditions
  mkdir -p "$(dirname "$CACHE_FILE")"
  if touch "$CACHE_FILE" 2>/dev/null; then
    chmod 600 "$CACHE_FILE" 2>/dev/null || log_error "Failed to set permissions on cache file $CACHE_FILE"
  fi
  release_cache_lock
else
  # Fallback: if lock cannot be acquired, still ensure cache directory exists
  # and proceed with execution (better to run twice than skip security checks)
  # Avoid unnecessary timestamp updates if another process recently refreshed the cache
  mkdir -p "$(dirname "$CACHE_FILE")"
  if [ -f "$CACHE_FILE" ]; then
    if command -v stat >/dev/null 2>&1; then
      cache_mtime=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)
    else
      cache_mtime=$(date -r "$CACHE_FILE" +%s 2>/dev/null || echo 0)
    fi
    current_time=$(date +%s)
    if [ $((current_time - cache_mtime)) -ge "$CACHE_INTERVAL" ]; then
      if touch "$CACHE_FILE" 2>/dev/null; then
        chmod 600 "$CACHE_FILE" 2>/dev/null || log_error "Failed to set permissions on cache file $CACHE_FILE"
      fi
    fi
  else
    if touch "$CACHE_FILE" 2>/dev/null; then
      chmod 600 "$CACHE_FILE" 2>/dev/null || log_error "Failed to set permissions on cache file $CACHE_FILE"
    fi
  fi
fi

# Helper function: log error (optional)
LOG_ROTATION_CHECKED=0
log_error() {
  if [ "${ENABLE_SECURITY_PERMISSIONS_LOG:-0}" -eq 1 ]; then
    local log_file="${XDG_CACHE_HOME:-$HOME/.cache}/security-permissions-errors.log"
    mkdir -p "$(dirname "$log_file")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$log_file" 2>/dev/null || true
    
    # Simple log rotation (keep last 5 files, max 10KB each)
    # Only check once per script execution to avoid performance issues
    if [ "$LOG_ROTATION_CHECKED" -eq 0 ] && [ -f "$log_file" ]; then
      LOG_ROTATION_CHECKED=1
      local file_size
      if command -v stat >/dev/null 2>&1; then
        file_size=$(stat -c %s "$log_file" 2>/dev/null || stat -f %z "$log_file" 2>/dev/null || echo 0)
      else
        file_size=$(wc -c < "$log_file" 2>/dev/null || echo 0)
      fi
      if [ "$file_size" -gt 10240 ]; then
        for ((i=4; i>=1; i--)); do
          [ -f "${log_file}.$i" ] && mv "${log_file}.$i" "${log_file}.$((i+1))" 2>/dev/null || true
        done
        mv "$log_file" "${log_file}.1" 2>/dev/null || true
      fi
    fi
  fi
}

# Helper function: set file permission
set_file_permission() {
  local file="$1"
  local perm="${2:-600}"
  if [ -f "$file" ]; then
    if ! chmod "$perm" "$file" 2>/dev/null; then
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
    if ! chmod "$perm" "$dir" 2>/dev/null; then
      log_error "Failed to set permissions on $dir"
      if [ "${DEBUG_SECURITY_PERMISSIONS:-0}" -eq 1 ]; then
        echo "Error setting permissions on $dir" >&2
      fi
    fi
  fi
}

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

