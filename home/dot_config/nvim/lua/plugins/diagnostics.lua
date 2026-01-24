return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      -- Disable diagnostics by default
      -- Use <leader>ud to toggle on/off
      vim.diagnostic.enable(false)
    end,
  },
}
