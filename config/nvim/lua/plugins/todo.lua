if not vim.g.vscode then
  return {
    {
      "bun913/min-todo.vim",
      lazy = false,
      config = function()
        -- toggle task status in normal mode
        vim.api.nvim_set_keymap("n", "<C-c>", ":ToggleTask<CR>", {
          noremap = true,
          silent = true,
        })

        -- create new task in insert mode
        vim.api.nvim_set_keymap("i", "<C-c>", "<ESC>:CreateTask<CR>A", {
          noremap = true,
          silent = true,
        })

        -- open todo.md
        vim.api.nvim_set_keymap("n", "<Leader>t", ":tabe ~/todo.md<CR>", {
          noremap = true,
          silent = true,
        })
      end,
    },
  }
else
  return {}
end
