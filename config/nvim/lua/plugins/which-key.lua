if not vim.g.vscode then
  return {
    {
      "folke/which-key.nvim",
      cmd = { "WhichKey" },
    },
  }
else
  return {}
end
