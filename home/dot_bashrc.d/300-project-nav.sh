# shellcheck shell=bash
# Project navigation. Claude Code's built-in worktree support handles
# worktree management. This has no custom wt-* helpers.

# Jump to a ghq-managed repository
dev() {
  command -v ghq >/dev/null 2>&1 || {
    echo "ghq not installed" >&2
    return 1
  }
  local repo
  # shellcheck disable=SC2016  # {} and $() expand in fzf's preview shell
  repo=$(ghq list | fzf --prompt='repo> ' --preview 'ls -la "$(ghq root)/{}"') || return
  cd "$(ghq root)/$repo" || return
}
