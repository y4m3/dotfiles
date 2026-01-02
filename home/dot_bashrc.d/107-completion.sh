#!/usr/bin/env bash
# 107-completion.sh — Shell completion (bash-completion, gh, etc.)
# Category: 100-199 (Tool configuration: one tool per file, sequential numbering)

# Completion (interactive only)
if is_interactive; then
  # Enable bash-completion if available (git, docker, etc. completions)
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    # shellcheck source=/usr/share/bash-completion/bash_completion
    source /usr/share/bash-completion/bash_completion
  fi

  # gh - GitHub CLI completion
  if command -v gh > /dev/null 2>&1; then
    # 'gh completion -s bash' outputs a script; source it inline
    eval "$(gh completion -s bash)"
  fi
fi
