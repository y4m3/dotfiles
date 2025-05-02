# https://github.com/junegunn/fzf
# common
if command -v fzf > /dev/null 2>&1; then
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    export FZF_CTRL_R_OPTS="--height 40% --layout=reverse --border"
fi

if [ -n "$BASH_VERSION" ]; then
    # bash
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash

    _fzf_complete_ssh() {
        _fzf_complete "--prompt='SSH> '" -- "$@" < <(cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sort | uniq)
    }
    complete -F _fzf_complete_ssh -o default ssh

    # fzf-tab-completion for bash
    if [ -f ~/.fzf-tab-completion/bash/fzf-bash-completion.sh ]; then
        source ~/.fzf-tab-completion/bash/fzf-bash-completion.sh
        bind -x '"\t": fzf_bash_completion'
    fi

elif [ -n "$ZSH_VERSION" ]; then
    # zsh
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

    _fzf_complete_ssh() {
        _fzf_compgen_path --prompt='SSH> ' < <(awk '{print $1}' ~/.ssh/known_hosts | cut -f 1 -d ',' | uniq)
    }
    compdef _fzf_complete_ssh=ssh

    # fzf-tab-completion for zsh
    if [ -d ~/.fzf-tab ]; then
        source ~/.fzf-tab/fzf-tab.plugin.zsh
        source ~/.fzf-tab/fzf-tab.zsh
    fi
fi
