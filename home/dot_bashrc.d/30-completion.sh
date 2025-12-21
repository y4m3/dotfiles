#!/usr/bin/env bash
# 30-completion.sh — Shell completion and auxiliary tools initialization.

# Enable bash-completion if available (git, docker, etc. completions)
if [ -f /usr/share/bash-completion/bash_completion ]; then
  # shellcheck source=/usr/share/bash-completion/bash_completion
  source /usr/share/bash-completion/bash_completion
fi

# gh - GitHub CLI completion
if command -v gh >/dev/null 2>&1; then
  # 'gh completion -s bash' outputs a script; source it inline
  eval "$(gh completion -s bash)"
fi

# fzf - fuzzy finder integration (0.48.0+)
# Official setup using fzf --bash (provides key bindings and completion)
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"

  # FZF environment variables for customization
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_DEFAULT_OPTS='--height 40% --reverse --border --inline-info --color=dark'

  # Ctrl-T: file search options
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {} 2>/dev/null || head -20 {}'"

  # Ctrl-R: history search options
  export FZF_CTRL_R_OPTS="--height 50% --reverse"

  # Alt-C: directory change options
  export FZF_ALT_C_OPTS="--preview 'eza --tree --color=auto {} 2>/dev/null | head -20'"
fi
