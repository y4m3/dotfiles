return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Disable diagnostics by default
      -- Use <leader>ud to toggle on/off
      vim.diagnostic.enable(false)
      return opts
    end,
  },
}
