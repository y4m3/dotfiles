#!/usr/bin/env bash
# 020-user-preferences.sh — Bash-specific user preferences

# Readline: enable vi editing mode (interactive only)
if is_interactive; then
  set -o vi
  alias_if_not_set "free" "free -h"
fi
