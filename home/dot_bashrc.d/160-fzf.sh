#!/usr/bin/env bash
# 160-fzf.sh — Tool configuration: fzf
# Category: 1xx (Tool configuration)
# See: https://github.com/junegunn/fzf

# fzf - fuzzy finder integration (interactive only)
if is_interactive; then
  if command -v fzf > /dev/null 2>&1; then
    # Official setup using fzf --bash (provides key bindings and completion)
    eval "$(fzf --bash)"

    # Use fd as default command (faster and respects .fdignore)
    if command -v fd > /dev/null 2>&1; then
      export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi

    # Basic UI options
    export FZF_DEFAULT_OPTS='--height 40% --reverse --border'

    # File preview (if bat is available)
    if command -v bat > /dev/null 2>&1; then
      export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {} 2>/dev/null || head -20 {}'"
    fi

    # Directory preview (if eza is available)
    if command -v eza > /dev/null 2>&1; then
      export FZF_ALT_C_OPTS="--preview 'eza --tree --color=auto {} 2>/dev/null | head -20'"
    fi
  fi
fi
