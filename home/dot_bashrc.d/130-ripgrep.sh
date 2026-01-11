#!/usr/bin/env bash
# 130-ripgrep.sh — Tool configuration: ripgrep
# Category: 1xx (Tool configuration)
# See: https://github.com/BurntSushi/ripgrep

# Aliases (interactive only)
if is_interactive; then
  if command -v rg > /dev/null 2>&1; then
    alias_if_not_set "grep" "rg"
  fi
fi
