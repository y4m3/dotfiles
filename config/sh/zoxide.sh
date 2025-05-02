# https://github.com/ajeetdsouza/zoxide
if command -v zoxide > /dev/null 2>&1; then
    if [ -n "$BASH_VERSION" ]; then
        eval "$(zoxide init bash)"
    elif [ -n "$ZSH_VERSION" ]; then
        eval "$(zoxide init zsh)"
    fi
fi
