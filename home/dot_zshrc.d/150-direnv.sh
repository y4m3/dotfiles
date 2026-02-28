#!/bin/zsh
# 150-direnv.sh — Tool configuration: direnv (zsh)

# direnv shell integration (loads .envrc per directory)
if command -v direnv > /dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
