#!/usr/bin/env bash
# 75-security-permissions.sh — Security: strict file permissions for credentials
# Automatically sets strict permissions on credential files and directories

# Apply security rule: set permissions on a path if it exists
# Usage: apply_security_rule <path> <permission>
# Permission: 600 (file), 700 (directory)
apply_security_rule() {
  local path="$1"
  local perm="$2"
  
  if [ -e "$path" ]; then
    if ! chmod "$perm" "$path" 2>&1; then
      # Error handling: only show errors in debug mode
      if [ "${DEBUG_SECURITY_PERMISSIONS:-0}" -eq 1 ]; then
        echo "Error setting permissions on $path" >&2
      fi
    fi
  fi
}

# Apply file rule with optional content check
# Usage: apply_file_rule <path> <permission> [pattern]
# If pattern is provided, only set permissions if file contains the pattern
apply_file_rule() {
  local path="$1"
  local perm="$2"
  local pattern="${3:-}"
  
  if [ ! -f "$path" ]; then
    return 0
  fi
  
  # If pattern is provided, check if file contains it
  # Use case-insensitive matching if pattern starts with (?i)
  if [ -n "$pattern" ]; then
    local grep_opts="-qE"
    if [[ "$pattern" =~ ^\(\?i\) ]]; then
      # Remove (?i) prefix and use case-insensitive grep
      pattern="${pattern#(?i)}"
      grep_opts="-qiE"
    fi
    if ! grep $grep_opts "$pattern" "$path" 2>/dev/null; then
      return 0  # Pattern not found, skip
    fi
  fi
  
  apply_security_rule "$path" "$perm"
}

# Apply directory rule
# Usage: apply_directory_rule <path> <permission>
apply_directory_rule() {
  local path="$1"
  local perm="$2"
  
  if [ -d "$path" ]; then
    apply_security_rule "$path" "$perm"
  fi
}

# Apply pattern rule: set permissions on files matching a pattern
# Usage: apply_pattern_rule <pattern> <permission>
# Example: apply_pattern_rule "$HOME/.ssh/id_*" 600
apply_pattern_rule() {
  local pattern="$1"
  local perm="$2"
  
  # Use find to match pattern and set permissions
  if command -v find >/dev/null 2>&1; then
    find "$(dirname "$pattern")" -maxdepth 1 -name "$(basename "$pattern")" -type f 2>/dev/null | while read -r file; do
      apply_security_rule "$file" "$perm"
    done
  fi
}

# GitHub CLI token security
apply_directory_rule "$HOME/.config/gh" 700
apply_file_rule "$HOME/.config/gh/hosts.yml" 600

# SSH key security
apply_directory_rule "$HOME/.ssh" 700
# Private key files (common names)
for key_file in "$HOME/.ssh"/id_rsa "$HOME/.ssh"/id_ed25519 "$HOME/.ssh"/id_ecdsa "$HOME/.ssh"/id_dsa; do
  apply_file_rule "$key_file" 600
done
# Config and authorized_keys
apply_file_rule "$HOME/.ssh/config" 600
apply_file_rule "$HOME/.ssh/authorized_keys" 600
# known_hosts can remain 644 (readable by group/others is acceptable)
# Public keys (*.pub) can remain 644

# Git credential helper security
apply_file_rule "$HOME/.git-credentials" 600

# npm/yarn credential security
apply_file_rule "$HOME/.npmrc" 600 "(//.*:.*@|_authToken|registry.*token)"

# Docker credential security
apply_directory_rule "$HOME/.docker" 700
apply_file_rule "$HOME/.docker/config.json" 600 '"auths"'

# Python credential security
apply_file_rule "$HOME/.pypirc" 600
apply_file_rule "$HOME/.pip/pip.conf" 600 "(?i)(password|token|key)"  # Case-insensitive pattern

# Rust credential security
if [ -f "$HOME/.cargo/credentials" ] || [ -f "$HOME/.cargo/credentials.toml" ]; then
  apply_directory_rule "$HOME/.cargo" 700
fi
apply_file_rule "$HOME/.cargo/credentials" 600
apply_file_rule "$HOME/.cargo/credentials.toml" 600

# GPG key security
apply_directory_rule "$HOME/.gnupg" 700
# Set permissions on GPG files if they exist
for gpg_file in "$HOME/.gnupg"/secring.gpg "$HOME/.gnupg"/private-keys-v1.d; do
  if [ -e "$gpg_file" ]; then
    if [ -d "$gpg_file" ]; then
      apply_security_rule "$gpg_file" 700
    else
      apply_security_rule "$gpg_file" 600
    fi
  fi
done
