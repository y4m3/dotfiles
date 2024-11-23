if not vim.g.vscode then
  return {
    { "dstein64/vim-startuptime" },
    {
      "goolord/alpha-nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("alpha").setup(require("alpha.themes.startify").config)
      end,
    },
  }
else
  return {}
end
