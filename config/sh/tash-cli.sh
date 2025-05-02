# https://github.com/andreafrancia/trash-cli
if command -v trash-put > /dev/null 2>&1; then
    alias rm='trash-put'
fi
