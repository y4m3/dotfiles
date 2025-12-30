#!/usr/bin/env bash
# 75-security-permissions.sh — Security: strict file permissions for credentials
# Automatically sets strict permissions on credential files and directories

# Performance optimization: skip if run recently
CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/security-permissions-last-run"
CACHE_INTERVAL="${SECURITY_PERMISSIONS_CACHE_INTERVAL:-300}"  # 5 minutes default

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
    return 0  # Skip execution
  fi
fi

# Helper function: set file permission
set_file_permission() {
  local file="$1"
  local perm="${2:-600}"
  if [ -f "$file" ]; then
    if ! chmod "$perm" "$file" 2>/dev/null; then
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
if [ -f "$HOME/.cargo/credentials" ] || [ -f "$HOME/.cargo/credentials.toml" ]; then
  set_dir_permission "$HOME/.cargo" 700
fi
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

# Update timestamp
mkdir -p "$(dirname "$CACHE_FILE")"
touch "$CACHE_FILE" 2>/dev/null || true
