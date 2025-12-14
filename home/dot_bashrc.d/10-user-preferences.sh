#!/usr/bin/env bash
# Personal preferences

# Set timezone to JST
export TZ=Asia/Tokyo

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