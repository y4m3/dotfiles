return {
  -- shellcheck comes from Nix (see .chezmoidata/packages.yaml). No Mason
  -- install needed. This skips bash-language-server (Node-based). nvim
  -- assigns bash files ft=sh, so only sh needs wiring.
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        -- shfmt is already LazyVim's default sh formatter. Only override
        -- its args to match the repo's ./lint (shfmt -i 2). This way,
        -- editor formatting and CI lint never disagree.
        shfmt = {
          prepend_args = { "-i", "2" },
        },
      },
    },
  },
}
