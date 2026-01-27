#!/usr/bin/env bash
# tmux-sessionizer alias

is_interactive || return

alias_if_not_set tm tmux-sessionizer
