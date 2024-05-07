#!/bin/bash

DOTFILES_PATH="$HOME/dotfiles"

find "$DOTFILES_PATH/config" -mindepth 1 -maxdepth 1 | while read -r item; do
  item_name=$(basename "$item")
  target_path="$HOME/.config/$item_name"

  if [ -L "$target_path" ]; then
    # If the target is already a symlink, remove it
    rm "$target_path"
  elif [ -e "$target_path" ]; then
    # If the target exists and is not a symlink, move it to a backup directory
    backup_dir="$HOME/.config/backup"
    mkdir -p "$backup_dir"
    mv "$target_path" "$backup_dir/"
  fi

  # Create the symlink
  ln -s "$item" "$target_path"
  echo "Linked: $item_name"
done

echo "Configuration files and folders have been linked to ~/.config"
