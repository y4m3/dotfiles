if not vim.g.vscode then
  return {
    {
      "renerocksai/telekasten.nvim",
      dependencies = {
        "iamcco/markdown-preview.nvim",
        "renerocksai/calendar-vim",
      },
      opts = function()
        local home = vim.fn.expand("~/zettelkasten")
        local templ_dir = vim.fn.stdpath("config") .. "/zettelkasten/templates"
        return {
          home = home,
          templates = templ_dir,
          dailies = home .. "/" .. "daily",
          extension = ".md",
          image_link_style = "markdown",
          subdirs_in_links = true,
          template_handling = "smart",
          new_note_location = "smart",
          rename_update_links = true,
          follow_creates_nonexisting = true,
          dailies_create_nonexisting = true,
          weeklies_create_nonexisting = true,
          template_new_note = templ_dir .. "/new_note.md",
          template_new_daily = templ_dir .. "/new_daily.md",
          journal_auto_open = true,
          sort = "modified",
        }
      end,
      keys = {
        { "<leader>z", "<cmd>Telekasten panel<CR>", desc = "Open Telekasten panel" },
        { "<leader>zf", "<cmd>Telekasten find_notes<CR>", desc = "Find notes using Telescope (telekasten)" },
        { "<leader>zg", "<cmd>Telekasten search_notes<CR>", desc = "Search notes using Telescope (telekasten)" },
        { "<leader>zd", "<cmd>Telekasten goto_today<CR>", desc = "Go to today's daily note (telekasten)" },
        { "<leader>zz", "<cmd>Telekasten follow_link<CR>", desc = "Follow link under cursor (telekasten)" },
        { "<leader>zn", "<cmd>Telekasten new_note<CR>", desc = "Create new note (telekasten)" },
        { "<leader>zc", "<cmd>Telekasten show_calendar<CR>", desc = "Show calendar (telekasten)" },
        { "<leader>zb", "<cmd>Telekasten show_backlinks<CR>", desc = "Show backlinks (telekasten)" },
        { "<leader>zI", "<cmd>Telekasten insert_img_link<CR>", desc = "Insert image link (telekasten)" },
        { "i[[", "<cmd>Telekasten insert_link<CR>", mode = "i", desc = "Insert link (telekasten)" },
      },
      config = function(_, opts)
        require("telekasten").setup(opts)
      end,
    },
  }
else
  return {}
end
