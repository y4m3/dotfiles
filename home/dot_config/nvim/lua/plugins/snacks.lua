return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- Nix environment: dynamically find libsqlite3.so for picker frecency
      -- Cache the result to avoid running expensive shell command on every startup
      local sqlite_path = vim.g.snacks_sqlite_path
      if sqlite_path == nil then
        local result = vim.fn.system(
          "nix-store -qR ~/.nix-profile 2>/dev/null | xargs -I{} find {} -path '*-sqlite-*/lib/libsqlite3.so' 2>/dev/null | head -1"
        ):gsub("%s+$", "")
        if result ~= "" then
          sqlite_path = result
        else
          -- Use false as sentinel to indicate no sqlite path found
          sqlite_path = false
        end
        vim.g.snacks_sqlite_path = sqlite_path
      end

      opts.image = { enabled = true }

      if sqlite_path and sqlite_path ~= "" then
        opts.picker = opts.picker or {}
        opts.picker.db = opts.picker.db or {}
        opts.picker.db.sqlite3_path = sqlite_path
      end

      return opts
    end,
  },
}
