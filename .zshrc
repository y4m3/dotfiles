#########################################
# PATH
########################################
# language
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# nvim
export XDG_CONFIG_HOME="$HOME/.config"

# uesr installation
export PATH="$HOME/.local/bin:$PATH"

# local
source $HOME/.zsh_local

########################################
# zplug
########################################
export ZPLUG_HOME=$HOME/.zplug
source $ZPLUG_HOME/init.zsh

zplug 'zplug/zplug', hook-build:'zplug --self-manage'

zplug "b4b4r07/enhancd", use:init.sh
zplug "mollifier/cd-gitroot"
zplug "mollifier/zload"
zplug "plugins/colorize", from:oh-my-zsh
zplug "plugins/docker", from:oh-my-zsh
zplug "plugins/osx", from:oh-my-zsh
zplug "RobSis/zsh-completion-generator", if:"GENCOMPL_FPATH=$HOME/.zsh/complete"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf
zplug "junegunn/fzf", as:command, use:bin/fzf-tmux
zplug "Tarrasch/zsh-autoenv"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
      echo; zplug install
  fi
fi

# Then, source plugins and add commands to $PATH
zplug load

########################################
# OS type
########################################
case ${OSTYPE} in
# macOS
darwin*)
  alias ls='ls -GF'
;;
# ubuntu
linux*)
  alias ls='ls --color=auto'
  alias pbcopy='xsel --clipboard --input'
  alias pbpaste='xsel --clipboard --output'
;;
esac

########################################
# settings
########################################
autoload -Uz colors; colors
autoload zmv
bindkey -v
colors
HISTFILE=~/.zsh_history
HISTSIZE=1000000
HISTTIMEFORMAT="[%Y/%M/%D %H:%M:%S] "
SAVEHIST=1000000
setopt auto_cd
setopt auto_menu
setopt auto_param_keys
setopt auto_param_slash
setopt auto_pushd
setopt complete_in_word
setopt correct
setopt extended_glob
setopt extended_history
setopt globdots
setopt hist_expand
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt ignore_eof
setopt inc_append_history
setopt interactive_comments
setopt list_packed
setopt list_types
setopt mark_dirs
setopt no_beep
setopt nolistbeep
setopt print_eight_bit
setopt prompt_subst
setopt pushd_ignore_dups
setopt share_history
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# prompt git status
# left prompt
PROMPT="%{%F{004}%}[%m][%3~]%{$reset_color%} %(!.#.$) "

### git status
function rprompt-git-current-branch {
    local branch_name st branch_status
    if [ ! -e  ".git" ]; then
        return
    fi
    branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
    st=`git status 2> /dev/null`
    if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
        branch_status="%F{green}"
    elif [[ -n `echo "$st" | grep "^Untracked files"` ]]; then
        branch_status="%F{red}?"
    elif [[ -n `echo "$st" | grep "^Changes not staged for commit"` ]]; then
        branch_status="%F{red}+"
    elif [[ -n `echo "$st" | grep "^Changes to be committed"` ]]; then
        branch_status="%F{yellow}!"
    elif [[ -n `echo "$st" | grep "^rebase in progress"` ]]; then
        echo "%F{red}!(no branch)"
        return
    else
        branch_status="%F{blue}"
    fi
        echo "${branch_status}[$branch_name]"
}
setopt prompt_subst
RPROMPT='`rprompt-git-current-branch`'

# window name
set -g set-titles on
set -g set-titles-string '#W'

# alias
alias cp='cp -i'
alias mkdir='mkdir -p'
alias mv='mv -i'
alias r='R --no-save --no-restore'
alias rm='rm -i'

alias gs='git status'
alias gl="git log --graph --date=short --decorate=short --pretty=format:'%Cgreen%h %Creset%cd %Cblue%cn %Cred%d %Creset%s'"

# auto ls
function chpwd() {
if [ 20 -gt `ls -1 | wc -l` ]; then
    ls
else
    ls
fi
}

########################################
# cd-gitroot
########################################
alias cdu='cd-gitroot'

########################################
# fzf
########################################
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--no-height --no-reverse'
export FZF_CTRL_T_OPTS="--select-1 --exit-0 --preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
export FZF_CTRL_R_OPTS="--sort --exact --preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
