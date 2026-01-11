#!/usr/bin/env bash
# 150-direnv.sh — Tool configuration: direnv
# Category: 1xx (Tool configuration)
# See: https://direnv.net/

# direnv shell integration (loads .envrc per directory)
# Non-interactive shells also need this (e.g., scripts using direnv)
if command -v direnv > /dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi
