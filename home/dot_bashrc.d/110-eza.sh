#!/usr/bin/env bash
# 110-eza.sh — Tool configuration: eza
# Category: 1xx (Tool configuration)
# See: https://github.com/eza-community/eza

# Aliases (interactive only)
if is_interactive; then
  if command -v eza > /dev/null 2>&1; then
    alias_if_not_set "ls" "eza --color=auto --group-directories-first --icons"
    alias_if_not_set "ll" "eza -alF --git --icons"
    alias_if_not_set "la" "eza -a --icons"
    alias_if_not_set "tree" "eza --tree --color=auto --group-directories-first --icons"
  else
    # Fallback to GNU ls with color when eza is not available
    alias_if_not_set "ls" "ls --color=auto"
  fi
fi
