#!/bin/zsh
# 210-starship.sh — Starship prompt (zsh)

# Starship prompt (interactive only)
if is_interactive; then
  if command -v starship > /dev/null 2>&1; then
    eval "$(starship init zsh)"
  fi
fi
