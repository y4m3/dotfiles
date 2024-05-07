if not vim.g.vscode then
  return {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
    config = function()
      require("no-neck-pain").setup({
        width = 90,
        buffers = {
          wo = {
            fillchars = "eob: ",
          },
        },
      })
    end,
    keys = {
      {
        "<leader>np",
        "<cmd>NoNeckPain<cr>",
        desc = "Toggle No Neck Pain",
      },
    },
  }
else
  return {}
end
