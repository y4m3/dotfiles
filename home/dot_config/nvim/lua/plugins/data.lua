return {
  -- yamllint guards packages.yaml (the repo's single source of truth);
  -- binary comes from Nix like shellcheck/shfmt.
  {
    "mfussenegger/nvim-lint",
    opts = { linters_by_ft = { yaml = { "yamllint" } } },
  },
  -- jsonls is Node-based (not adopted); prettier (already installed for
  -- markdown) covers formatting, treesitter covers highlighting.
  {
    "stevearc/conform.nvim",
    opts = { formatters_by_ft = { json = { "prettier" }, jsonc = { "prettier" } } },
  },
  -- Column-aligned CSV viewing (pure Lua, no deps). Loads on csv/tsv
  -- buffers; toggle manually with :CsvViewToggle.
  {
    "hat0uma/csvview.nvim",
    ft = { "csv", "tsv" },
    opts = {},
  },
}
