#!/bin/zsh
# 170-completion.sh — Shell completion (zsh)

# Completion (interactive only)
if is_interactive; then
  # Initialize zsh completion system
  autoload -Uz compinit && compinit

  # gh - GitHub CLI completion
  if command -v gh > /dev/null 2>&1; then
    eval "$(gh completion -s zsh)"
  fi

  # carapace - Multi-shell completion framework
  if command -v carapace > /dev/null 2>&1; then
    source <(carapace _carapace zsh)
  fi
fi
