#!/usr/bin/env bash
# 180-ghq-worktree.sh — ghq and git worktree integration
# Dependencies: fzf, ghq, git

GHQ_ROOT="${GHQ_ROOT:-$HOME/repos}"
WORKTREE_DIR="${WORKTREE_DIR:-${GHQ_ROOT}/.worktrees}"

if is_interactive && command -v fzf > /dev/null 2>&1 && command -v ghq > /dev/null 2>&1; then

  # dev: Navigate to ghq repository or worktree
  dev() {
    local selected
    selected=$({
      ghq list --full-path
      [[ -d "$WORKTREE_DIR" ]] && find "$WORKTREE_DIR" -mindepth 2 -maxdepth 2 -type d -exec test -f {}/.git \; -print 2> /dev/null
    } | sort -u | fzf --prompt="Repository: " --preview 'ls -la {}')
    [[ -z "$selected" ]] && return 0
    cd "$selected" || return 1
  }

  # wt-add [branch]: Create worktree
  wt-add() {
    git rev-parse --git-dir > /dev/null 2>&1 || {
      echo "Error: Not in a git repository" >&2
      return 1
    }
    local repo branch path
    repo=$(basename "$(git rev-parse --show-toplevel)")
    if [[ -n "${1:-}" ]]; then
      branch="$1"
    else
      git fetch --all --prune || echo "Warning: git fetch failed" >&2
      branch=$(git branch -r | grep -v HEAD | sed 's/^[[:space:]]*origin\///' | fzf --prompt="Branch: ")
      [[ -z "$branch" ]] && return 0
      branch=$(echo "$branch" | xargs)
    fi
    path="${WORKTREE_DIR}/${repo}/${branch//[\/.]/-}"
    [[ -d "$path" ]] && {
      cd "$path" || return 1
      return 0
    }
    mkdir -p "$(dirname "$path")"
    if git show-ref --verify --quiet "refs/heads/${branch}"; then
      git worktree add "$path" "$branch"
    elif git show-ref --verify --quiet "refs/remotes/origin/${branch}"; then
      git worktree add "$path" -b "$branch" "origin/${branch}"
    else
      git worktree add "$path" -b "$branch"
    fi && { cd "$path" || return 1; }
  }

  # wt-rm [path]: Remove worktree
  wt-rm() {
    git rev-parse --git-dir > /dev/null 2>&1 || {
      echo "Error: Not in a git repository" >&2
      return 1
    }
    local path main
    main=$(git worktree list --porcelain | head -1 | sed 's/^worktree //')
    if [[ -n "${1:-}" ]]; then
      path="$1"
    else
      path=$(git worktree list --porcelain | grep '^worktree ' | sed 's/^worktree //' | grep -v "^${main}$" | fzf --prompt="Remove: ")
      [[ -z "$path" ]] && return 0
    fi
    [[ "$(pwd)" == "$path"* ]] && { cd "$main" || return 1; }
    if [[ -n "$(git -C "$path" status --porcelain 2> /dev/null)" ]]; then
      read -rp "Has uncommitted changes. Remove? [y/N] " r
      [[ ! "$r" =~ ^[Yy] ]] && return 1
    fi
    git worktree remove "$path" --force
  }

  wt-list() { git rev-parse --git-dir > /dev/null 2>&1 && git worktree list; }
  wt-prune() { git rev-parse --git-dir > /dev/null 2>&1 && git worktree prune -v; }

fi

true
