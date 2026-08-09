# shellcheck shell=bash
# Aliases. One file; guard each tool with command -v.

# Safety
alias cp='cp -i'
alias mv='mv -i'
alias df='df -h'
alias du='du -h'
alias mkdir='mkdir -p'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
  alias ll='eza -l --git'
  alias la='eza -la --git'
  alias lt='eza --tree --level=2'
fi

if command -v bat >/dev/null 2>&1; then
  # -pp: plain style, no pager; colors still apply on a tty
  alias cat='bat -pp'
fi
