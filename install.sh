#!/bin/zsh

DOTFILES_DIR=${0:a:h}

# install tpm
echo "${(r:5::=:)} INSTALL TPM ${(r:62::=:)}"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "\n${(r:5::=:)} ADD SYMBOLIC LINK ${(r:56::=:)}"
# set config files
ln -svf $DOTFILES_DIR/zsh/zshrc $HOME/.zshrc
ln -svf $DOTFILES_DIR/vim/vimrc $HOME/.vimrc
ln -svf $DOTFILES_DIR/tmux/tmux.conf $HOME/.tmux.conf

# add environment-dependent settings
touch $HOME/.zshrc.local

echo "\n${(r:5::=:)} DONE ${(r:69::=:)}"
