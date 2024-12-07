if not vim.g.vscode then
  return {
    -- Solarized Theme
    -- {
    --   "maxmx03/solarized.nvim",
    --   lazy = false,
    --   priority = 1000,
    --   opts = {
    --     theme = "neo",
    --     transparent = true,
    --   },
    --   config = function(_, opts)
    --     vim.o.background = "dark"
    --     vim.cmd.colorscheme("solarized")
    --     require("lualine").setup({
    --       options = {
    --         icons_enabled = true,
    --         theme = "solarized_dark",
    --       },
    --     })
    --   end,
    -- },
    -- Tokyo Night Theme
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      opts = {
        style = "moon",
        transparent = true,
        styles = {
          sidebars = "dark",
          floats = "dark",
        },
      },
      config = function(_, opts)
        vim.o.background = "dark"
        require("tokyonight").setup(opts)
        vim.cmd.colorscheme("tokyonight")
        require("lualine").setup({
          options = {
            icons_enabled = true,
            theme = "tokyonight",
          },
        })
      end,
    },
    -- Transparent Plugin
    {
      "xiyaowong/transparent.nvim",
      opts = {
        extra_groups = {
          "NormalFloat", -- Plugins with float panels (e.g., Lazy, Mason, LspInfo)
          "NvimTreeNormal", -- NvimTree
        },
      },
      config = function(_, opts)
        require("transparent").setup(opts)
        -- Clear specific prefixes for transparency
        for _, prefix in ipairs({ "NeoTree", "lualine", "bufferline" }) do
          require("transparent").clear_prefix(prefix)
        end
      end,
    },
  }
else
  return {}
end
