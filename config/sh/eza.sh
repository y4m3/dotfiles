# https://github.com/eza-community/eza
if command -v eza &> /dev/null; then
    alias ls="eza --icons --git"
    alias la="eza -a --icons --git"
    alias lt="eza -T -L 3 -a -I 'node_modules|.git|.cache' --icons"
    alias lta="eza -T -a -I 'node_modules|.git|.cache' --color=always --icons | less -r"
    alias l="clear && ls"
else
    alias ll='ls -l'
    alias la='ls -la'
fi
