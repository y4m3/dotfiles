#!/usr/bin/env bash
# 140-fd.sh — Tool configuration: fd
# Category: 1xx (Tool configuration)
# See: https://github.com/sharkdp/fd

# Aliases (interactive only)
if is_interactive; then
  if command -v fd > /dev/null 2>&1; then
    alias_if_not_set "find" "fd"
  fi
fi
