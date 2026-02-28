#!/bin/sh
# tmux-sessionizer alias

is_interactive || return

alias_if_not_set tm tmux-sessionizer
