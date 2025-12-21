#!/usr/bin/env bash
# 40-runtimes.sh — Language runtime manager initialization
# This file should only perform existence checks and safe initializations

# Rust (Cargo)
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# Starship prompt (enabled via PROMPT_STYLE=starship)
if command -v starship >/dev/null 2>&1; then
    if [ "${PROMPT_STYLE:-}" = "starship" ]; then
        eval "$(starship init bash)"

       __append_history_to_prompts() { builtin history -a; }
        PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }__append_history_to_prompts"
    fi
fi
