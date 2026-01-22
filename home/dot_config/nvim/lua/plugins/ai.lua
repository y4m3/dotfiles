-- AI tools customizations (overrides for LazyVim extras)
-- sidekick.nvim uses copilot.lua's bundled LSP server for Next Edit Suggestions (NES)

return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      filetypes = {
        gitcommit = true,
        yaml = true,
      },
    },
  },
  {
    "folke/sidekick.nvim",
    opts = {
      cli = {
        mux = {
          backend = vim.env.TMUX and "tmux" or nil,
        },
      },
    },
    keys = {
      { "<C-\\>", function() require("sidekick.cli").toggle() end, desc = "Sidekick Toggle", mode = { "n", "t", "i", "x" } },
    },
  },
}
