if not vim.g.vscode then
  return {
    -- vim-startuptime Plugin
    {
      "dstein64/vim-startuptime",
    },
    -- alpha-nvim Plugin
    {
      "goolord/alpha-nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = function()
        local startify = require("alpha.themes.startify")
        return startify.config
      end,
      config = function(_, opts)
        require("alpha").setup(opts)
      end,
    },
  }
else
  return {}
end
