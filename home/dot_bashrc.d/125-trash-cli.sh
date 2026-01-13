#!/usr/bin/env bash
# trash-cli: Safe file deletion
# Moves files to trash instead of permanent deletion

# Only run in interactive shells
is_interactive || return 0

# Only enable trash-cli integration if trash-cli is available
if command -v trash-put > /dev/null 2>&1 && command -v trash-list > /dev/null 2>&1; then
  # Block rm command to prevent accidental permanent deletion
  # shellcheck disable=SC2317
  rm() {
    printf '\e[2mThis is not the command you are looking for.\e[0m\n' >&2
    printf '\e[2mUse: tp (trash) or del (permanent)\e[0m\n' >&2
    return 1
  }

  # tp: Move to trash with feedback
  tp() {
    if [[ $# -eq 0 ]]; then
      printf '\e[2mUsage: tp <file>...\e[0m\n' >&2
      return 1
    fi
    command trash-put "$@"
    local status=$?
    if [[ $status -eq 0 ]]; then
      printf '\e[2mtrashed\e[0m\n'
    fi
    return "$status"
  }

  # del: Permanent deletion with confirmation
  alias del='command rm -i'

  # Trash management commands
  alias trash='trash-list'
  alias tl='trash-list'
fi
