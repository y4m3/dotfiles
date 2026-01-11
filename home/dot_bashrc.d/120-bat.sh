#!/usr/bin/env bash
# 120-bat.sh — Tool configuration: bat
# Category: 1xx (Tool configuration)
# See: https://github.com/sharkdp/bat

# Environment variables (non-interactive also needs this)
# Default values can be overridden in ~/.bashrc.local
# Tokyo Night themes are installed via .chezmoiexternal.toml
: "${BAT_THEME:=tokyonight_storm}" # Theme: tokyonight_day, tokyonight_moon, tokyonight_night, tokyonight_storm
: "${BAT_PAGER:=less -FRX}"        # -R: preserve colors, -F: exit if one screen, -X: don't clear screen

export BAT_THEME BAT_PAGER

# Smart cat function (interactive only)
# Replaces cat with bat for interactive viewing, but uses real cat for pipes/redirects
if is_interactive; then
  cat() {
    # Non-interactive stdout (pipe / redirect) -> use real cat
    if ! [ -t 1 ]; then
      command /bin/cat "$@"
      return
    fi

    # No arguments -> read from stdin (preserve cat's default behavior)
    if [ $# -eq 0 ]; then
      command /bin/cat
      return
    fi

    # Interactive view with arguments -> prefer bat/batcat
    if command -v bat > /dev/null 2>&1; then
      command bat --paging=auto "$@"
    elif command -v batcat > /dev/null 2>&1; then
      # Debian/Ubuntu package name
      command batcat --paging=auto "$@"
    else
      # No bat available -> keep cat semantics (avoid less multi-file/concat mismatch)
      command /bin/cat "$@"
    fi
  }
fi
