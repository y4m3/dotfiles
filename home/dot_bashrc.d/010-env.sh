# shellcheck shell=bash
# Editor and pager environment. Sourced for non-interactive shells too
# (from ~/.bashrc, before the interactive guard): exports only.

if command -v nvim >/dev/null 2>&1; then
  export EDITOR=nvim VISUAL=nvim
else
  export EDITOR=vi VISUAL=vi
fi

export LESS="-R -F -M -i"

export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# bat/delta use "ansi" so colors follow the terminal's color scheme
# (Tracer). No .tmTheme downloads or bat cache builds needed.
export BAT_THEME=ansi
