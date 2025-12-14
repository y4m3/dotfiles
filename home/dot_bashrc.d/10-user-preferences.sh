#!/usr/bin/env bash
# Personal preferences

# Editor (override locally if desired)
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"

# Readline: enable vi editing mode
set -o vi

# Safety and convenience
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias mkdir='mkdir -pv'

# Custom aliases (personal favorites)
alias gs='git status'
alias gl='git log --oneline --graph --decorate --all'