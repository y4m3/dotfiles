-- LSP configuration for Nix-managed environment
-- Python tools (ruff, pyright) are installed via Nix (see home.nix),
-- not Mason, because the Nix environment's Python doesn't have pip.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Disable Mason installation for Nix-managed LSP servers
        ruff = {
          mason = false,
        },
        pyright = {
          mason = false,
        },
      },
    },
  },
}
