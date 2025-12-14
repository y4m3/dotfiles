#!/usr/bin/env bash
# 60-utils.sh — General-purpose utilities (tmux/ssh integration, small helper functions)
# Optional utilities and small helpers used by interactive shells.

# Optional: enable automatic `ls` after cd by setting ENABLE_CD_LS=1
# in ~/.bashrc.local (keeps behavior opt-in and host-local).
if [ "${ENABLE_CD_LS:-0}" -eq 1 ]; then
  cd() { builtin cd "$@" && ls; }
fi
