#!/usr/bin/env bash
# direnv shell integration (loads .envrc per directory)
if command -v direnv > /dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi
