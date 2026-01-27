return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false,
        signs = false,
        underline = true,
      },
    },
    keys = {
      {
        "<leader>ud",
        function()
          local current = vim.diagnostic.config()
          local enabled = current.virtual_text or current.signs
          if enabled then
            vim.diagnostic.config({ virtual_text = false, signs = false })
            vim.notify("Diagnostics disabled", vim.log.levels.INFO)
          else
            vim.diagnostic.config({
              virtual_text = {
                spacing = 4,
                source = "if_many",
                prefix = "●",
              },
              signs = true,
            })
            vim.notify("Diagnostics enabled", vim.log.levels.INFO)
          end
        end,
        desc = "Toggle Diagnostics",
      },
    },
  },
}
