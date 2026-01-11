#!/usr/bin/env bash
# 210-starship.sh — Starship prompt
# Category: 2xx (Prompt)

# Starship prompt (enabled via PROMPT_STYLE=starship)
# Interactive only (prompt is interactive-only)
if is_interactive; then
  if command -v starship > /dev/null 2>&1; then
    if [ "${PROMPT_STYLE:-}" = "starship" ]; then
      eval "$(starship init bash)"

      __append_history_to_prompts() { builtin history -a; }
      PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }__append_history_to_prompts"
    fi
  fi
fi
