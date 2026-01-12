#!/usr/bin/env bash
# 170-completion.sh — Shell completion (bash-completion, gh, carapace)
# Category: 1xx (Tool configuration)

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

# carapace - Multi-shell completion framework
if is_interactive && command -v carapace &> /dev/null; then
  source <(carapace _carapace)
fi
