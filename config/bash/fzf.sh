# https://github.com/junegunn/fzf
if command -v fzf &> /dev/null; then
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash

    _fzf_complete_ssh() {
      _fzf_complete "--prompt='SSH> '" -- "$@" < <(cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sort | uniq)
    }
    complete -F _fzf_complete_ssh -o default ssh

    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    export FZF_CTRL_R_OPTS="--height 40% --layout=reverse --border"
fi

if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
  source /usr/share/doc/fzf/examples/key-bindings.bash
fi

# https://github.com/lincheney/fzf-tab-completion
if [ -f ~/.fzf-tab-completion/bash/fzf-bash-completion.sh ]; then
  source ~/.fzf-tab-completion/bash/fzf-bash-completion.sh
  bind -x '"\t": fzf_bash_completion'
fi
