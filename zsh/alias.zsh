# git
alias gl="git log --graph --date=short --decorate=short --pretty=format:'%Cgreen%h %Creset%cd %Cblue%cn %Cred%d %Creset%s'"
alias gs='git status'
alias gr='cd $(git rev-parse --show-toplevel)'

# bat
alias cat="bat"

# lsd
if builtin command -v lsd > /dev/null; then
  alias ls=lsd
  alias l='lsd -l'
  alias la='lsd -al'
  alias lt='lsd --tree'
fi
