return {
  -- Nix supplies Linux; mise and uv supply Windows editor tools.
  -- Both platforms deploy this config. Keep Mason off to avoid duplicates.
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Python: ty (Astral) does types/completion/navigation. ruff (set
        -- up by the python extra) does lint/format. pyright stays
        -- available via `uvx pyright` for independent checks. This file
        -- does not wire it in.
        ty = {},
        pyright = { enabled = false },
      },
    },
  },
}
