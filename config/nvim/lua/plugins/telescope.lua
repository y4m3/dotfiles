if not vim.g.vscode then
  return {
    {
      "nvim-telescope/telescope.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-file-browser.nvim",
        "nvim-telescope/telescope-ui-select.nvim",
        {
          "nvim-telescope/telescope-media-files.nvim",
          dependencies = { "nvim-lua/popup.nvim" },
        },
        "dharmx/telescope-media.nvim",
        "nvim-telescope/telescope-symbols.nvim",
      },
      opts = {
        defaults = {
          path_display = { "truncate" },
          mappings = {
            i = {
              ["<C-j>"] = require("telescope.actions").move_selection_next,
              ["<C-k>"] = require("telescope.actions").move_selection_previous,
              ["<esc>"] = require("telescope.actions").close,
            },
            n = {
              ["j"] = require("telescope.actions").move_selection_next,
              ["k"] = require("telescope.actions").move_selection_previous,
            },
          },
        },
        extensions = {
          media_files = {
            filetypes = { "png", "webp", "jpg", "jpeg", "pdf" },
            find_cmd = "rg",
          },
        },
      },
      keys = {
        { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files using Telescope" },
        { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep using Telescope" },
        { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "List open buffers using Telescope" },
        { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Search help tags using Telescope" },
        { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Show keymaps using Telescope" },
        { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Open recently opened files using Telescope" },
        { "<space>fd", "<cmd>Telescope file_browser<CR>", desc = "Open file browser using Telescope" },
      },
      config = function(_, opts)
        require("telescope").setup(opts)
        require("telescope").load_extension("file_browser")
        require("telescope").load_extension("ui-select")
        require("telescope").load_extension("media_files")
      end,
    },
    {
      "prochri/telescope-all-recent.nvim",
      dependencies = {
        "kkharji/sqlite.lua",
        "stevearc/dressing.nvim",
      },
    },
  }
else
  return {}
end
