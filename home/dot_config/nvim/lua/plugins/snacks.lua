return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- Nix environment: dynamically find libsqlite3.so for picker frecency
      local sqlite_path = vim.fn.system(
        "nix-store -qR ~/.nix-profile 2>/dev/null | xargs -I{} find {} -name 'libsqlite3.so' 2>/dev/null | head -1"
      ):gsub("%s+$", "")

      opts.image = { enabled = true }

      if sqlite_path ~= "" then
        opts.picker = opts.picker or {}
        opts.picker.db = opts.picker.db or {}
        opts.picker.db.sqlite3_path = sqlite_path
      end
    end,
  },
}
