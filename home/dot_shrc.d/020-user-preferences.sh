#!/bin/sh
# 020-user-preferences.sh — Common user preferences (bash/zsh)

# Safety and convenience aliases (interactive only)
# Note: rm is handled by 125-trash-cli.sh
if is_interactive; then
  alias_if_not_set "cp" "cp -i"
  alias_if_not_set "mv" "mv -i"
  alias_if_not_set "df" "df -h"
  alias_if_not_set "du" "du -h"
  alias_if_not_set "mkdir" "mkdir -pv"
fi
