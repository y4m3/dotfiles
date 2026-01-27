-- zettel-meta.nvim: Frontmatter-aware file display for Zettelkasten workflows

return {
  {
    "y4m3/zettel-meta.nvim",
    lazy = true,
    event = { "VeryLazy", "FileType markdown" },
    cmd = { "ZmFiles", "ZmRecent", "ZmTags", "ZmFilterPick", "ZmRefresh" },
    keys = {
      {
        "<leader>oq",
        function()
          require("zettel-meta").pick_files()
        end,
        desc = "Quick switch (title)",
      },
      {
        "<leader>or",
        function()
          require("zettel-meta").recent_files()
        end,
        desc = "Recent notes",
      },
      {
        "<leader>og",
        function()
          require("zettel-meta").pick_tags()
        end,
        desc = "Tags",
      },
      {
        "<leader>op",
        function()
          require("zettel-meta").pick_files({ filter = { type = "permanent" } })
        end,
        desc = "Permanent notes",
      },
      {
        "<leader>of",
        function()
          require("zettel-meta").pick_files_with_filter()
        end,
        desc = "Filter notes",
      },
    },
    -- workspaces auto-detected from OBSIDIAN_VAULTS env var
    -- integrations setup() automatically hooks into each plugin
    opts = {
      title_marker = "*",
      cache_ttl = 60,
      auto_refresh = true,
      integrations = {
        snacks = true,
        bufferline = true,
        incline = true,
        neo_tree = false,
        lualine = false,
      },
    },
  },
}
