#!/usr/bin/env bash
# 010-aliases-helper.sh — Helper functions for alias management
# Provides common functions for setting aliases in interactive shells
# while respecting user-defined aliases in .bashrc.local
#
# This file must be loaded first (000 prefix ensures lexicographic order)
# before any alias-setting files (100-*, 101-*, etc.)

# Check if shell is interactive
# Returns 0 if interactive, 1 otherwise
# See: docs/design-principles/bash-init-design.md
is_interactive() {
  case "$-" in
    *i*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# Set alias only if not already defined
# Usage: alias_if_not_set <alias_name> <alias_value>
# Example: alias_if_not_set "ls" "eza --color=auto"
#
# This function respects user-defined aliases in .bashrc.local
# by checking if the alias is already defined before setting it.
alias_if_not_set() {
  local alias_name="$1"
  local alias_value="$2"

  # Check if alias is already defined (e.g., in .bashrc.local)
  if ! alias "$alias_name" > /dev/null 2>&1; then
    # shellcheck disable=SC2139
    # Variable expansion in alias is intentional here
    alias "$alias_name"="$alias_value"
  fi
}

# Ensure sourcing this file never returns a non-zero status (bashrc.d hygiene).
true
