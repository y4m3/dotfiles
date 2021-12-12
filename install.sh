#!/bin/zsh

DOTFILES_DIR=${0:a:h}

# install tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# set config files
ln -svf $DOTFILES_DIR/zsh/zshrc $HOME/.zshrc
ln -svf $DOTFILES_DIR/vim/vimrc $HOME/.vimrc
ln -svf $DOTFILES_DIR/tmux/tmux.conf $HOME/.tmux.conf

# add environment-dependent settings
touch $HOME/.zshrc.local
