#!/usr/bin/env bash
# 20-paths.sh — Common PATH management and version manager initialization

# Prepend a directory to PATH if not already present
path_prepend() {
  case ":$PATH:" in
  *":$1:") : ;;
  *) PATH="$1:$PATH" ;;
  esac
}

# Basic/system paths (keep minimal and safe)
path_prepend "/usr/local/sbin"
path_prepend "/usr/local/bin"
path_prepend "/usr/sbin"
path_prepend "/usr/bin"
path_prepend "/sbin"
path_prepend "/bin"

# User-specific prepends (idempotent)
path_prepend "$HOME/.fzf/bin"
path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"

# Remove duplicate entries while preserving order
_old_ifs="$IFS"
IFS=:
_new=""
for p in $PATH; do
  case ":$_new:" in
  *":$p:") ;; # already present
  *) if [ -z "$_new" ]; then _new="$p"; else _new="$_new:$p"; fi ;;
  esac
done
IFS="$_old_ifs"
PATH="$_new"

# Ensure user bins are present (conditional)
if [ -d "$HOME/.cargo/bin" ]; then
  case ":$PATH:" in *":$HOME/.cargo/bin:"*) : ;; *) PATH="$HOME/.cargo/bin:$PATH" ;; esac
fi
if [ -d "$HOME/.local/bin" ]; then
  case ":$PATH:" in *":$HOME/.local/bin:"*) : ;; *) PATH="$HOME/.local/bin:$PATH" ;; esac
fi

export PATH
