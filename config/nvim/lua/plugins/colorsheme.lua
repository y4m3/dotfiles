if not vim.g.vscode then
  return {
    -- {
    --   "maxmx03/solarized.nvim",
    --   lazy = false,
    --   priority = 1000,
    --   config = function()
    --     vim.o.background = "dark"
    --     vim.cmd.colorscheme("solarized")
    --     transparent = true
    --     theme = "neo"
    --
    --     require("lualine").setup({
    --       options = {
    --         icons_enabled = true,
    --         theme = "solarized_dark",
    --       },
    --     })
    --   end,
    -- },
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      opts = {},
      config = function()
        vim.o.background = "dark"
        vim.cmd.colorscheme("tokyonight")

        require("tokyonight").setup({
          -- style = "storm",
          style = "moon",
          -- style = "night",
          -- style = "day", -- need background = "light"
          transparent = true,
        })

        require("lualine").setup({
          options = {
            icons_enabled = true,
            theme = "tokyonight",
          },
        })
      end,
    },
  }
else
  return {}
end
