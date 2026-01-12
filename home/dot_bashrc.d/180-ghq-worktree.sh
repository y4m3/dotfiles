#!/usr/bin/env bash
# 180-ghq-worktree.sh — Tool configuration: ghq and git worktree integration
# Category: 1xx (Tool configuration)
# Dependencies: fzf (160-fzf.sh), ghq, git
# See: https://github.com/x-motemen/ghq
# Reference: https://zenn.dev/shunk031/articles/ghq-gwq-fzf-worktree

# Configuration (can be overridden in ~/.bashrc.local)
GHQ_ROOT="${GHQ_ROOT:-$HOME/repos}"
WORKTREE_DIR="${WORKTREE_DIR:-${GHQ_ROOT}/.worktrees}"

if is_interactive; then
  # Require both fzf and ghq for full functionality
  if command -v fzf > /dev/null 2>&1 && command -v ghq > /dev/null 2>&1; then

    # dev: Navigate to ghq repository or worktree using fzf
    # Usage: dev
    dev() {
      local selected_path preview_cmd

      # Set preview command based on available tools
      if command -v eza > /dev/null 2>&1; then
        preview_cmd='eza --tree --color=always --level=2 {} 2>/dev/null || ls -la {}'
      else
        preview_cmd='ls -la {}'
      fi

      # Combine ghq repositories and worktrees
      selected_path=$({
        ghq list --full-path
        if [[ -d "$WORKTREE_DIR" ]]; then
          find "$WORKTREE_DIR" -mindepth 2 -maxdepth 2 -type d 2> /dev/null | while read -r dir; do
            # Only include directories that are git worktrees
            if [[ -f "${dir}/.git" ]]; then
              echo "$dir"
            fi
          done
        fi
      } | sort -u | fzf --prompt="Repository: " --preview "$preview_cmd")

      [[ -z "$selected_path" ]] && return 0

      cd "$selected_path" || return 1

      # Rename tmux session if inside tmux
      if [[ -n "${TMUX:-}" ]]; then
        local session_name
        session_name="${selected_path##*/}"
        session_name="${session_name//./-}"
        tmux rename-session "$session_name" 2> /dev/null || true
      fi
    }

    # wt-add: Create a new git worktree
    # Usage: wt-add [branch-name]
    #   Without args: Select from remote branches using fzf
    #   With args: Create new branch with given name
    wt-add() {
      if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        return 1
      fi

      local repo_name branch_name worktree_path
      repo_name=$(basename "$(git rev-parse --show-toplevel)")

      if [[ -n "${1:-}" ]]; then
        branch_name="$1"
      else
        git fetch --all --prune 2> /dev/null
        branch_name=$(git branch -r |
          grep -v 'HEAD' |
          sed 's/^[[:space:]]*origin\///' |
          fzf --prompt="Branch: ")
        [[ -z "$branch_name" ]] && return 0
        branch_name=$(echo "$branch_name" | xargs)
      fi

      # Use a filesystem-friendly name for the worktree directory to avoid
      # creating nested paths when branch names contain slashes (e.g. feature/x).
      local branch_dir_name="${branch_name//\//-}"
      branch_dir_name="${branch_dir_name//./-}"
      worktree_path="${WORKTREE_DIR}/${repo_name}/${branch_dir_name}"

      if [[ -d "$worktree_path" ]]; then
        echo "Worktree already exists: $worktree_path"
        echo "Moving to existing worktree..."
        cd "$worktree_path" || return 1
        return 0
      fi

      mkdir -p "$(dirname "$worktree_path")"

      local worktree_created=false
      if git show-ref --verify --quiet "refs/heads/${branch_name}" 2> /dev/null; then
        if git worktree add "$worktree_path" "$branch_name"; then
          worktree_created=true
        fi
      elif git show-ref --verify --quiet "refs/remotes/origin/${branch_name}" 2> /dev/null; then
        if git worktree add "$worktree_path" -b "$branch_name" "origin/${branch_name}"; then
          worktree_created=true
        fi
      else
        if git worktree add "$worktree_path" -b "$branch_name"; then
          worktree_created=true
        fi
      fi

      if [[ "$worktree_created" == "true" ]]; then
        echo "Created worktree: $worktree_path"
        cd "$worktree_path" || return 1

        if [[ -n "${TMUX:-}" ]]; then
          local session_name="${branch_name//\//-}"
          session_name="${session_name//./-}"
          tmux rename-session "$session_name" 2> /dev/null || true
        fi
      else
        echo "Error: Failed to create worktree for branch '$branch_name'" >&2
        return 1
      fi
    }

    # wt-rm: Remove a git worktree
    # Usage: wt-rm [worktree-path]
    #   Without args: Select from existing worktrees using fzf
    wt-rm() {
      if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        return 1
      fi

      local worktree_path main_worktree

      if [[ -n "${1:-}" ]]; then
        worktree_path="$1"
      else
        main_worktree=$(git worktree list --porcelain | head -1 | sed 's/^worktree //')
        worktree_path=$(git worktree list --porcelain |
          grep '^worktree ' |
          sed 's/^worktree //' |
          grep -v "^${main_worktree}$" |
          fzf --prompt="Remove worktree: ")
        [[ -z "$worktree_path" ]] && return 0
      fi

      # Move out if currently in the worktree being removed
      if [[ "$(pwd)" == "$worktree_path"* ]]; then
        echo "Currently in worktree. Moving to main repository..."
        main_worktree=$(git worktree list --porcelain | head -1 | sed 's/^worktree //')
        cd "$main_worktree" || cd ~ || return 1
      fi

      # Warn if the worktree has uncommitted or untracked changes
      if git -C "$worktree_path" rev-parse --git-dir > /dev/null 2>&1; then
        if [[ -n "$(git -C "$worktree_path" status --porcelain 2> /dev/null)" ]]; then
          echo "Warning: Worktree '$worktree_path' has uncommitted changes or untracked files."
          read -r -p "Remove worktree and discard these changes? [y/N] " reply
          case "$reply" in
            [Yy][Ee][Ss] | [Yy]) ;;
            *)
              echo "Aborted worktree removal."
              return 1
              ;;
          esac
        fi
      fi

      echo "Removing worktree: $worktree_path"
      git worktree remove "$worktree_path" --force

      # Remove empty parent directories
      local parent_dir
      parent_dir=$(dirname "$worktree_path")
      while [[ "$parent_dir" != "$WORKTREE_DIR" ]] && [[ -d "$parent_dir" ]]; do
        if [[ -z "$(ls -A "$parent_dir" 2> /dev/null)" ]]; then
          rmdir "$parent_dir" 2> /dev/null
          parent_dir=$(dirname "$parent_dir")
        else
          break
        fi
      done
    }

    # wt-list: List all worktrees for current repository
    wt-list() {
      if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        return 1
      fi
      git worktree list
    }

    # wt-prune: Remove stale worktree references
    wt-prune() {
      if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        return 1
      fi
      git worktree prune -v
    }

  elif command -v ghq > /dev/null 2>&1; then
    # Fallback: ghq only (without fzf)
    # Provides a simple numbered menu for selection.
    dev() {
      local repos=() repo_count i choice repo

      # Collect repositories managed by ghq
      while IFS= read -r repo; do
        [[ -n "$repo" ]] && repos+=("$repo")
      done < <(ghq list)

      repo_count=${#repos[@]}

      if ((repo_count == 0)); then
        echo "No repositories found. Use 'ghq get <repo>' to clone." >&2
        return 1
      elif ((repo_count == 1)); then
        # Preserve previous behavior: go directly to the single repository
        cd "$(ghq root)/${repos[0]}" || return 1
        return 0
      fi

      echo "Select repository (ghq fallback without fzf):"
      for ((i = 0; i < repo_count; i++)); do
        printf '  %2d) %s\n' "$((i + 1))" "${repos[i]}"
      done
      echo "  q) Cancel"

      while :; do
        read -r -p "Enter choice [1-${repo_count}] (or 'q' to cancel): " choice

        case "$choice" in
          q | Q | '')
            echo "Selection cancelled."
            return 1
            ;;
        esac

        if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= repo_count)); then
          repo=${repos[choice - 1]}
          cd "$(ghq root)/$repo" || return 1
          return 0
        else
          echo "Invalid selection: '$choice'. Please enter a number between 1 and ${repo_count}, or 'q' to cancel."
        fi
      done
    }
  fi
fi

# Ensure sourcing this file never returns a non-zero status (bashrc.d hygiene).
true
