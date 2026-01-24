#!/usr/bin/env bash
# 020-user-preferences.sh — User preferences
# Category: 0xx (Core)
# Sets safety aliases and vi mode

# Timezone managed by Home Manager (home.sessionVariables.TZ)

# Editor settings moved to 100-editor.sh

# Readline: enable vi editing mode (interactive only)
if is_interactive; then
  set -o vi
fi

# Safety and convenience aliases (interactive only)
# Note: rm is handled by 125-trash-cli.sh
if is_interactive; then
  alias_if_not_set "cp" "cp -i"
  alias_if_not_set "mv" "mv -i"
  alias_if_not_set "df" "df -h"
  alias_if_not_set "du" "du -h"
  alias_if_not_set "free" "free -h"
  alias_if_not_set "mkdir" "mkdir -pv"
fi
