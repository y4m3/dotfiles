# theme
zinit ice depth=1; zinit light romkatv/powerlevel10k

# zsh tab completions
zinit ice wait"0b" lucid blockf
zinit light zsh-users/zsh-completions
zstyle ":completion:*:git-checkout:*" sort false
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm,cmd -w -w"
zstyle ':completion:*:descriptions' format '-- %d --'
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:complete:*:options' sort false

# syntax highlighting
zinit ice wait lucid
zinit light zdharma-continuum/fast-syntax-highlighting

# zsh auto suggestion
zinit light zsh-users/zsh-autosuggestions
bindkey '^j' autosuggest-accept

# fzf
zinit ice from"gh-r" as"command"
zinit light junegunn/fzf

export FZF_DEFAULT_COMMAND='rg --files --hidden'
export FZF_DEFAULT_OPTS="--ansi --reverse --inline-info --height 100% --border --preview-window=right:70%:rounded:cycle:wrap --bind=?:toggle-preview"
export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_OPTS='--height 90% --reverse --border --preview "bat --color=always --style=header,grid --line-range :200 {}"'
export FZF_ALT_C_OPTS="--exit-0 --preview 'tree -C -N -q {} | head -200'"

zle -N fzf-cd-widget
bindkey '^N' fzf-cd-widget
zle -N fzf-file-widget
bindkey '^P' fzf-file-widget

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
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:complete:_zlua:*' query-string input
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -l --color=always $realpath'
zstyle ':fzf-tab:complete:kill:argument-rest' extra-opts --preview=$extract'ps --pid=$in[(w)1] -o cmd --no-headers -w -w' --preview-window=down:3:wrap

# upgrade cd
zinit ice wait'1' lucid pick'init.sh'
zinit light "b4b4r07/enhancd"

# upgrade ls
zinit ice wait lucid as"program" from"gh-r" mv"lsd* -> lsd" pick"lsd/lsd"
zinit light Peltoche/lsd

# bat (upgrade cat)
zinit ice wait lucid as"program" from"gh-r" mv"bat* -> bat" pick"bat/bat"
zinit light sharkdp/bat

# fd (upgrade find)
zinit ice as"program" from"gh-r" mv"fd* -> fd" pick"fd/fd"
zinit light sharkdp/fd

# ripgrep (upgrade grep)
zinit ice as"program" from"gh-r" mv"ripgrep* -> rg" pick"rg/rg"
zinit light BurntSushi/ripgrep
