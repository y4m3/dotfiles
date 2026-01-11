#!/usr/bin/env bash
# 030-paths.sh — PATH management
# Category: 0xx (Core) (Core functionality)

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
path_prepend "$HOME/.local/go/bin"
path_prepend "$HOME/go/bin"
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"

# Nix paths (highest priority - must be last)
if [ -d "$HOME/.nix-profile/bin" ]; then
  path_prepend "$HOME/.nix-profile/bin"
fi

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

export PATH
