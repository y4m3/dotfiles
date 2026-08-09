# shellcheck shell=bash
# Tool hooks that modify the prompt or bind keys. Each initialized exactly once.

# --- Prompt: 2-line prompt, git branch/state via git's bundled git-prompt.sh
# Line 1: [✗ mark, red, only when the last command's exit code was non-zero]
#         [nix/venv indicator, cyan]
#         user@host (green; yellow over SSH) + abbreviated path (blue)
#         + git state (magenta, via __git_ps1)
# Line 2: [background job count, bright black, only when >=1] \$ (bash's
#         standard prompt char; becomes # for root)
# Git markers: * unstaged  + staged  % untracked  $ stash
#              <>= upstream behind/ahead (verbose: u+N/-N counts)
# Heavy-repo escape hatch: git config bash.showDirtyState false

# Colors: ANSI base codes only. The actual hue is up to the terminal's color
# scheme (Tracer); adjust the numbers below to retheme the prompt.
__pc_exit='31' # exit code (red)
__pc_env='36'  # nix/venv indicator (cyan)
__pc_host='32' # user@host (green; overridden to 33/yellow over SSH)
__pc_path='34' # path (blue)
__pc_git='35'  # git state (magenta)
__pc_jobs='90' # background job count (bright black)

# SSH state never changes for the life of the session, so decide once here.
if [ -n "${SSH_CONNECTION:-}" ] || [ -n "${SSH_TTY:-}" ]; then
  __pc_host='33'
fi

# Abbreviate $PWD for display: $HOME -> ~, then, only if the whole path
# exceeds 40 columns, shorten components from the left (never the last one)
# to their first character (two characters for dotfiles, e.g. .local -> .l)
# until it fits. Ported from statusline-command.sh's abbrev_path, reading
# $PWD directly instead of taking an argument.
__prompt_pwd() {
  local p="$PWD" max=40
  if [[ "$p" == "$HOME" ]]; then
    printf '~'
    return
  fi
  [[ "$p" == "$HOME"/* ]] && p="~${p#"$HOME"}"

  local parts joined seg i n
  IFS='/' read -ra parts <<<"$p"
  local IFS='/'
  n=${#parts[@]}
  for ((i = 0; i < n - 1; i++)); do
    joined="${parts[*]}"
    ((${#joined} <= max)) && break
    seg="${parts[i]}"
    [[ -z "$seg" || "$seg" == "~" ]] && continue
    if [[ "$seg" == .* ]]; then
      parts[i]="${seg:0:2}"
    else
      parts[i]="${seg:0:1}"
    fi
  done
  printf '%s' "${parts[*]}"
}

# Segments that can change on every prompt: exit code of the last command, a
# nix-shell/venv indicator (direnv can flip these mid-session), and the
# background job count. Writes plain text (no color escapes) into globals
# that PS1 references via ${...} (promptvars expansion); PS1 supplies the
# \[\e[Nm\]...\[\e[0m\] wrapper around them, so an empty segment costs zero
# display width. Must run before any other PROMPT_COMMAND entry (e.g.
# `history -a`), since those would clobber $? before it is captured here.
__prompt_refresh() {
  local ec=$?

  __prompt_exit=""
  # shellcheck disable=SC2034  # consumed by PS1 via promptvars expansion
  ((ec != 0)) && __prompt_exit="✗ "

  __prompt_env=""
  [ -n "${IN_NIX_SHELL:-}" ] && __prompt_env+="❄ "
  # shellcheck disable=SC2034
  [ -n "${VIRTUAL_ENV:-}" ] && __prompt_env+="($(basename "$VIRTUAL_ENV")) "

  local n
  n=$(jobs -p | wc -l)
  __prompt_jobs=""
  # shellcheck disable=SC2034
  ((n > 0)) && __prompt_jobs="&${n} "
}

__git_prompt="$HOME/.nix-profile/share/git/contrib/completion/git-prompt.sh"
PS1='\[\e['"${__pc_exit}"'m\]${__prompt_exit}\[\e[0m\]'
PS1+='\[\e['"${__pc_env}"'m\]${__prompt_env}\[\e[0m\]'
PS1+='\[\e['"${__pc_host}"'m\]\u@\h\[\e[0m\] '
PS1+='\[\e['"${__pc_path}"'m\]$(__prompt_pwd)\[\e[0m\]'
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
  GIT_PS1_SHOWUPSTREAM=verbose
  PS1+='$(__git_ps1 " (\[\e['"${__pc_git}"'m\]%s\[\e[0m\])")'
fi
PS1+='\n\[\e['"${__pc_jobs}"'m\]${__prompt_jobs}\[\e[0m\]\$ '
unset __git_prompt __pc_exit __pc_env __pc_host __pc_path __pc_git __pc_jobs

# Share history across sessions: write after each prompt (-a) and read what
# other sessions wrote (-n). __prompt_refresh must run first so it captures
# $? from the last command, not from `history`. Guarded so re-sourcing
# .bashrc does not stack. A shell still running the old config (which set
# `history -a; history -n` without __prompt_refresh) only needs the prefix
# added, not another copy of the history calls.
case "${PROMPT_COMMAND:-}" in
*"__prompt_refresh"*) ;;
*"history -a"*) PROMPT_COMMAND="__prompt_refresh; ${PROMPT_COMMAND}" ;;
*) PROMPT_COMMAND="__prompt_refresh; history -a; history -n${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
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
