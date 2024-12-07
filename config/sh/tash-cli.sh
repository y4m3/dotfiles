# https://github.com/andreafrancia/trash-cli
if command -v trash-put > /dev/null; then
    alias rm='trash-put'
fi
