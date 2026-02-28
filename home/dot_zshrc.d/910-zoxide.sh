#!/bin/zsh
# 910-zoxide.sh — Tool configuration: zoxide (zsh)

# Environment variables (non-interactive also needs this)
export _ZO_RESOLVE_SYMLINKS=1
export _ZO_ECHO=1
export _ZO_EXCLUDE_DIRS="/tmp:/var/tmp:/run:/proc:/sys:/dev:/snap:$HOME/.cache:$HOME/.local/share:$HOME/**/node_modules:$HOME/**/__pycache__:$HOME/**/.venv:$HOME/**/.git"

# Initialization (interactive only)
if is_interactive; then
  if command -v zoxide > /dev/null 2>&1; then
    # Replace 'j' command with zoxide jump
    eval "$(zoxide init zsh --cmd j)"

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

    # Optional: auto-ls after cd when zoxide-backed (opt-in via ENABLE_CD_LS=1)
    if [ "${ENABLE_CD_LS:-0}" -eq 1 ] && command -v __zoxide_z > /dev/null 2>&1; then
      cd() {
        __zoxide_z "$@"
        local status=$?
        if [ $status -eq 0 ]; then ls; fi
        return $status
      }
    fi
  else
    # Without zoxide: optional auto-ls after cd
    if [ "${ENABLE_CD_LS:-0}" -eq 1 ]; then
      cd() { builtin cd "$@" && ls; }
    fi
  fi
fi
