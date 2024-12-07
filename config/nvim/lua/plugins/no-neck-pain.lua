if not vim.g.vscode then
  return {
    {
      "shortcuts/no-neck-pain.nvim",
      version = "*",
      opts = {
        width = 120,
        buffers = {
          wo = {
            fillchars = "eob: ",
          },
        },
      },
      keys = {
        {
          "<leader>np",
          "<cmd>NoNeckPain<cr>",
          desc = "Toggle No Neck Pain",
        },
      },
    },
  }
else
  return {}
end
