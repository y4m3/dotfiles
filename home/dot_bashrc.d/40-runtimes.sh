#!/usr/bin/env bash
# 40-runtimes.sh — Language runtime manager initialization
# This file should only perform existence checks and safe initializations

# Rust (Cargo)
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi
