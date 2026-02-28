#!/bin/zsh
# 020-user-preferences.sh — Zsh-specific user preferences

# Vi-style command line editing (interactive only)
if is_interactive; then
  bindkey -v
fi
