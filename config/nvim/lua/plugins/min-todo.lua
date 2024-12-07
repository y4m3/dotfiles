if not vim.g.vscode then
  return {
    {
      "bun913/min-todo.vim",
      lazy = false,
      keys = {
        {
          "<C-c>",
          ":ToggleTask<CR>",
          mode = "n",
          desc = "Toggle task status",
        },
        {
          "<C-c>",
          "<ESC>:CreateTask<CR>",
          mode = "i",
          desc = "Create new task",
        },
        {
          "<Leader>t",
          ":tabe ~/todo.md<CR>",
          mode = "n",
          desc = "Open todo.md",
        },
      },
    },
  }
else
  return {}
end
