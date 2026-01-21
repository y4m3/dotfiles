-- AI tools customizations (overrides for LazyVim extras)

-- Enable Copilot LSP for sidekick.nvim NES
vim.lsp.enable("copilot")

return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "copilot-language-server",
      },
    },
  },
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
