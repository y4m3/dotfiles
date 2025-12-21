#!/usr/bin/env bash
# Personal preferences

# Set timezone to JST
export TZ=Asia/Tokyo

# Editor (override locally if desired)
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"
export GIT_EDITOR="${GIT_EDITOR:-vim}"

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

# Tool-friendly aliases (enabled when tools are available)
# eza for ls family (exa is EOL)
if command -v eza > /dev/null 2>&1; then
  alias ls='eza --color=auto --group-directories-first'
  alias ll='eza -alF --git'
  alias la='eza -a'
  alias tree='eza --tree --color=auto --group-directories-first'
fi

# Prefer bat/batcat for cat
if command -v bat > /dev/null 2>&1; then
  alias cat='bat --plain'
elif command -v batcat > /dev/null 2>&1; then
  # Debian/Ubuntu package name
  alias bat='batcat'
  alias cat='batcat --plain'
fi

# Prefer ripgrep for grep
if command -v rg > /dev/null 2>&1; then
  alias grep='rg'
  # Config file is automatically loaded from ~/.ripgreprc
  export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
fi

# fd (fd-find) - modern find alternative
if command -v fd > /dev/null 2>&1; then
  alias find='fd'
  # Ignore patterns are automatically loaded from ~/.fdignore
fi
