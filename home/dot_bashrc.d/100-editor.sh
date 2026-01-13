#!/usr/bin/env bash
# 100-editor.sh — Editor configuration
# Category: 1xx (Tools)
# Sets EDITOR/VISUAL/GIT_EDITOR with nvim preference, vim fallback
# Provides history-aware v/vi/vim functions
# Depends on: is_interactive() from 010-aliases-helper.sh

# Detect preferred editor
# Note: _EDITOR_CMD is intentionally kept (used by functions at runtime)
if command -v nvim > /dev/null 2>&1; then
  _EDITOR_CMD="nvim"
else
  _EDITOR_CMD="vim"
fi

# Set environment variables (non-interactive also needs this)
export EDITOR="$_EDITOR_CMD"
export VISUAL="$_EDITOR_CMD"
export GIT_EDITOR="$_EDITOR_CMD"

# History-aware editor functions (interactive shell only)
if is_interactive; then
  # Helper to record properly quoted command in history
  _editor_history() {
    local cmd="$1"
    shift
    if (($#)); then
      local quoted
      quoted=$(printf '%q ' "$@")
      history -s "$cmd ${quoted% }"
    else
      history -s "$cmd"
    fi
  }

  # v, vi → detected editor (nvim or vim)
  v() {
    _editor_history "$_EDITOR_CMD" "$@"
    command "$_EDITOR_CMD" "$@"
  }

  vi() {
    _editor_history "$_EDITOR_CMD" "$@"
    command "$_EDITOR_CMD" "$@"
  }

  # vim → nvim if available, otherwise native vim
  if [[ "$_EDITOR_CMD" == "nvim" ]]; then
    vim() {
      _editor_history "nvim" "$@"
      command nvim "$@"
    }
  fi
fi
