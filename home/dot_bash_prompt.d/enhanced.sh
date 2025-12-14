#!/usr/bin/env bash
# Enhanced prompt: colored, shows exit status, git branch/dirty, python version, venv

__git_info() {
  command -v git >/dev/null 2>&1 || return
  local br
  br=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return
  local dirty=''
  git diff --quiet --ignore-submodules -- 2>/dev/null || dirty='*'
  printf '(%s%s)' "$br" "$dirty"
}

__python_version() {
  local pyver
  # Try to detect python version from .python-version or virtual environment
  if [ -f "$(pwd)/.python-version" ]; then
    pyver=$(cat "$(pwd)/.python-version")
    printf '[%s]' "$pyver"
  elif [ -n "${VIRTUAL_ENV:-}" ] && [ -f "$VIRTUAL_ENV/.python-version" ]; then
    pyver=$(cat "$VIRTUAL_ENV/.python-version")
    printf '[%s]' "$pyver"
  fi
}

__venv() {
  [ -n "${VIRTUAL_ENV:-}" ] && printf '[%s]' "$(basename "$VIRTUAL_ENV")"
}

__prompt_status() {
  [ "$__last_status" -eq 0 ] && printf '✓' || printf '✗'
}

# Keep PROMPT_COMMAND lightweight; store last status and append history
PROMPT_COMMAND='__last_status=$?; history -a'

# PS1 evaluated at prompt time to include dynamic info
# Format: ✓ user@host:cwd (branch*)[python-version][venv-name] $
PS1="\$(__prompt_status) \[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\] \$(__git_info)\$(__python_version)\$(__venv) \$ "
