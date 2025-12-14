#!/usr/bin/env bash
# Bare prompt: minimal, suitable for servers (no external dependencies required)
# Features: exit status (✓/✗), git branch with dirty mark

__git_branch_dirty() {
  command -v git >/dev/null 2>&1 || return
  local br
  br=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return
  local dirty=''
  git diff --quiet --ignore-submodules -- 2>/dev/null || dirty='*'
  printf '(%s%s)' "$br" "$dirty"
}

__prompt_status() {
  [ "$__last_status" -eq 0 ] && printf '✓' || printf '✗'
}

# Keep PROMPT_COMMAND lightweight; store last status and append history
PROMPT_COMMAND='__last_status=$?; history -a'

# PS1: ✓ (branch*) user@host:cwd $
# Success shows ✓, failure shows ✗; * indicates git dirty
PS1="\$(__prompt_status) \$(__git_branch_dirty) \u@\h:\w \$ "
