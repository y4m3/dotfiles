# shellcheck shell=bash
# Tool hooks that modify the prompt or bind keys. Each initialized exactly once.

# --- Prompt: git branch/state via git's bundled git-prompt.sh ---------------
# Markers: * unstaged  + staged  % untracked  $ stash  <>= upstream behind/ahead
# Heavy-repo escape hatch: git config bash.showDirtyState false
__git_prompt="$HOME/.nix-profile/share/git/contrib/completion/git-prompt.sh"
if [ -r "$__git_prompt" ]; then
  # shellcheck disable=SC1090
  . "$__git_prompt"
  # shellcheck disable=SC2034  # consumed by __git_ps1
  GIT_PS1_SHOWDIRTYSTATE=1
  # shellcheck disable=SC2034
  GIT_PS1_SHOWSTASHSTATE=1
  # shellcheck disable=SC2034
  GIT_PS1_SHOWUNTRACKEDFILES=1
  # shellcheck disable=SC2034
  GIT_PS1_SHOWUPSTREAM=auto
  PS1='\[\e[34m\]\w\[\e[0m\]$(__git_ps1 " (\[\e[35m\]%s\[\e[0m\])") \$ '
else
  PS1='\[\e[34m\]\w\[\e[0m\] \$ '
fi
unset __git_prompt

# Share history across sessions: write after each prompt (-a) and read what
# other sessions wrote (-n). Guarded so re-sourcing .bashrc does not stack.
case "${PROMPT_COMMAND:-}" in
*"history -a"*) ;;
*) PROMPT_COMMAND="history -a; history -n${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
esac

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# j <dir> to jump by frecency (keeps old muscle memory; zoxide default is z)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash --cmd j)"
fi

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi
