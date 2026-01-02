#!/usr/bin/env bash
# 103-fd.sh — Tool configuration: fd
# Category: 100-199 (Tool configuration: one tool per file, sequential numbering)
# See: https://github.com/sharkdp/fd

# Aliases (interactive only)
if is_interactive; then
  if command -v fd > /dev/null 2>&1; then
    alias_if_not_set "find" "fd"
  fi
fi
