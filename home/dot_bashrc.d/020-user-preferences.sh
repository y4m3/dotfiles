#!/usr/bin/env bash
# 020-user-preferences.sh — User preferences
# Category: 0xx (Core) (Core functionality)
# Sets timezone, editor, and safety aliases

# Set timezone to JST (non-interactive also needs this)
export TZ=Asia/Tokyo

# Editor (non-interactive also needs this)
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"
export GIT_EDITOR="${GIT_EDITOR:-vim}"

# Readline: enable vi editing mode (interactive only)
if is_interactive; then
  set -o vi
fi

# Safety and convenience aliases (interactive only)
if is_interactive; then
  alias_if_not_set "rm" "rm -i"
  alias_if_not_set "cp" "cp -i"
  alias_if_not_set "mv" "mv -i"
  alias_if_not_set "df" "df -h"
  alias_if_not_set "du" "du -h"
  alias_if_not_set "free" "free -h"
  alias_if_not_set "mkdir" "mkdir -pv"
fi
