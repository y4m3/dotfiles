if not vim.g.vscode then
  return {
    {
      "akinsho/toggleterm.nvim",
      version = "*",
      opts = {
        open_mapping = [[<C-Space><C-Space>]],
        desc = "Toggle the terminal window",
      },
    },
  }
else
  return {}
end
