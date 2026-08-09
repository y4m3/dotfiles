# shellcheck shell=bash
# Completion: system bash-completion framework + Nix-installed completions.
# bash-completion v2 lazily scans $XDG_DATA_DIRS/bash-completion/completions,
# so adding the Nix profile share dir covers git, gh, etc.

export XDG_DATA_DIRS="$HOME/.nix-profile/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

if ! shopt -oq posix && [ -f /usr/share/bash-completion/bash_completion ]; then
  # shellcheck disable=SC1091
  . /usr/share/bash-completion/bash_completion
fi
