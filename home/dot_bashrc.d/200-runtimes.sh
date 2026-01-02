#!/usr/bin/env bash
# 200-runtimes.sh — Language runtime manager initialization
# Category: 200-299 (Runtime initialization)
# This file should only perform existence checks and safe initializations

# Rust (Cargo) - non-interactive also needs this
if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi

# Optimize cargo build parallelism (for cargo install fallback when cargo-binstall compiles from source)
# This only affects source builds; prebuilt binaries from cargo-binstall are unaffected
# Use nproc - 1 to avoid overloading the system (leave 1 core free)
if [ -z "${CARGO_BUILD_JOBS:-}" ]; then
  if command -v nproc > /dev/null 2>&1; then
    # Ubuntu/Linux: use (CPU cores - 1) to avoid system overload
    cores=$(nproc)
    if [ "$cores" -gt 1 ]; then
      export CARGO_BUILD_JOBS=$((cores - 1))
    else
      export CARGO_BUILD_JOBS=1
    fi
  else
    # Fallback: use 4 parallel jobs if nproc is not available
    export CARGO_BUILD_JOBS=4
  fi
fi

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
