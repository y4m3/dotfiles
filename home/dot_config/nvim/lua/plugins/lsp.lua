return {
  -- One binary supplier: Nix (see .chezmoidata/packages.yaml). Mason stays
  -- off; this nvim config deploys only on Linux/WSL (.chezmoiignore skips
  -- it on Windows).
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Python: ty (Astral) does types/completion/navigation; ruff (set up
        -- by the python extra) does lint/format. pyright stays available for
        -- second opinions via `uvx pyright` without being wired in here.
        ty = {},
        pyright = { enabled = false },
      },
    },
  },
}
