if not vim.g.vscode then
  return {
    {
      "romgrk/barbar.nvim",
      dependencies = {
        "lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
        "nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
      },
      init = function()
        vim.g.barbar_auto_setup = false
      end,
      version = "^1.0.0", -- optional: only update when a new 1.x version is released
      config = function()
        vim.g.barbar_auto_setup = false
        require("barbar").setup({
          animation = true,
          auto_hide = false,
          tabpages = true,
          clickable = true,
          sidebar_filetypes = {
            ["neo-tree"] = {
              event = "BufWipeout",
            },
          },
        })
      end,
    },
  }
else
  return {}
end
