#!/usr/bin/env bash
# 60-utils.sh — General-purpose utilities (tmux/ssh integration, small helper functions)
# Optional utilities and small helpers used by interactive shells.

# Initialize zoxide (smart cd) if available
if command -v zoxide > /dev/null 2>&1; then
  export _ZO_RESOLVE_SYMLINKS=1
  export _ZO_ECHO=1
  export _ZO_EXCLUDE_DIRS="/tmp:/var/tmp:/run:/proc:/sys:/dev:/snap:$HOME/.cache:$HOME/.local/share:$HOME/**/node_modules:$HOME/**/__pycache__:$HOME/**/.venv:$HOME/**/.git"

  # Replace 'j' command with zoxide jump
  eval "$(zoxide init bash --cmd j)"

  # Wrapper for j: add/remove helpers, otherwise delegate to zoxide
  j() {
    if [[ "$1" == "add" ]]; then
      shift
      zoxide add "${1:-.}"
    elif [[ "$1" == "rm" || "$1" == "remove" ]]; then
      shift
      zoxide remove "$1"
    else
      if command -v __zoxide_z > /dev/null 2>&1; then
        __zoxide_z "$@"
      else
        zoxide "$@"
      fi
    fi
  }
  # Optional: auto-ls even when cd is zoxide-backed (opt-in via ENABLE_CD_LS=1)
  if [ "${ENABLE_CD_LS:-0}" -eq 1 ] && command -v __zoxide_z > /dev/null 2>&1; then
    cd() {
      __zoxide_z "$@"
      local status=$?
      if [ $status -eq 0 ]; then ls; fi
      return $status
    }
  fi
else
  # Optional: enable automatic `ls` after cd by setting ENABLE_CD_LS=1
  # in ~/.bashrc.local (keeps behavior opt-in and host-local).
  if [ "${ENABLE_CD_LS:-0}" -eq 1 ]; then
    cd() { builtin cd "$@" && ls; }
  fi
fi
