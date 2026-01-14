return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- Nix environment: dynamically find libsqlite3.so for picker frecency
      -- Cache to file to avoid running expensive shell command on every startup
      local cache_file = vim.fn.stdpath("cache") .. "/snacks_sqlite_path"
      local sqlite_path = vim.g.snacks_sqlite_path

      if sqlite_path == nil then
        -- Try to read from cache file first
        local f = io.open(cache_file, "r")
        if f then
          local cached = f:read("*l")
          f:close()
          if cached and cached ~= "" then
            sqlite_path = cached
          else
            sqlite_path = false
          end
        end

        -- If not cached, resolve and cache it (deferred to avoid blocking startup)
        if sqlite_path == nil then
          vim.schedule(function()
            local result = vim.fn.system(
              "nix-store -qR ~/.nix-profile 2>/dev/null | xargs -I{} find {} -path '*-sqlite-*/lib/libsqlite3.so' 2>/dev/null | head -1"
            ):gsub("%s+$", "")

            -- Write to cache file
            local cf = io.open(cache_file, "w")
            if cf then
              cf:write(result)
              cf:close()
            end

            if result ~= "" then
              vim.g.snacks_sqlite_path = result
              -- Update snacks config if already loaded
              local ok, snacks = pcall(require, "snacks")
              if ok and snacks.config and snacks.config.picker then
                snacks.config.picker.db = snacks.config.picker.db or {}
                snacks.config.picker.db.sqlite3_path = result
              end
            else
              vim.g.snacks_sqlite_path = false
            end
          end)
          sqlite_path = false -- Use false for this startup
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
