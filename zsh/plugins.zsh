# theme
zinit ice depth=1; zinit light romkatv/powerlevel10k

# zsh tab completions
zinit ice wait"0b" lucid blockf
zinit light zsh-users/zsh-completions
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*:descriptions' format '-- %d --'
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:complete:*:options' sort false
zstyle ':fzf-tab:complete:_zlua:*' query-string input
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm,cmd -w -w"
zstyle ':fzf-tab:complete:kill:argument-rest' extra-opts --preview=$extract'ps --pid=$in[(w)1] -o cmd --no-headers -w -w' --preview-window=down:3:wrap
zstyle ":completion:*:git-checkout:*" sort false
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# syntax highlighting
zinit ice wait lucid
zinit light zdharma-continuum/fast-syntax-highlighting

# zsh auto suggestion
zinit light zsh-users/zsh-autosuggestions
bindkey '^j' autosuggest-accept

# fzf
zinit ice from"gh-r" as"command"
zinit light junegunn/fzf

# fzf widgets
zinit ice lucid wait'0c' \
    multisrc"shell/{completion,key-bindings}.zsh" \
    id-as"junegunn/fzf_completions" \
    pick"/dev/null"
zinit light junegunn/fzf

# fzf tmux
zinit ice lucid wait'0c' as"command" id-as"junegunn/fzf-tmux" pick"bin/fzf-tmux"
zinit light junegunn/fzf

# fzf tab
zinit ice wait"1" lucid
zinit light Aloxaf/fzf-tab

# upgrade cd
zinit ice wait'1' lucid pick'init.sh'
zinit light "b4b4r07/enhancd"

# upgrade ls (exa)
zinit ice wait lucid as"program" from"gh-r" mv"lsd* -> lsd" pick"lsd/lsd"
zinit light Peltoche/lsd
if builtin command -v lsd > /dev/null; then
  alias ls=lsd
  alias la='lsd -al'
  alias l='ls -l'
  alias la='ls -a'
  alias lla='ls -la'
  alias lt='ls --tree'
fi

# bat (upgrade cat)
zinit ice wait lucid as"program" from"gh-r" mv"bat* -> bat" pick"bat/bat"
zinit light sharkdp/bat
alias cat="bat"

# bat-extras (bat plugins)
zinit ice wait"1" as"program" pick"src/batgrep.sh" lucid
zinit ice wait"1" as"program" pick"src/batdiff.sh" lucid
zinit light eth-p/bat-extras
alias rg=batgrep.sh
alias bd=batdiff.sh
alias man=batman.sh
