if not vim.g.vscode then
  return {
    {
      {
        "nvim-telescope/telescope.nvim",
        dependencies = {
          "nvim-lua/plenary.nvim",
          {
            "nvim-telescope/telescope-file-browser.nvim",
            config = function()
              vim.keymap.set("n", "<space>fd", ":Telescope file_browser<cr>", {
                noremap = true,
                desc = "Open file browser using Telescope",
              })
            end,
          },
          {
            "nvim-telescope/telescope-ui-select.nvim",
            config = function()
              require("telescope").load_extension("ui-select")
            end,
          },
          {
            "nvim-telescope/telescope-media-files.nvim",
            dependencies = { "nvim-lua/popup.nvim" },
            config = function()
              require("telescope").load_extension("media_files")
              require("telescope").setup({
                extensions = {
                  media_files = {
                    filetypes = { "png", "webp", "jpg", "jpeg", "pdf" },
                    find_cmd = "rg",
                  },
                },
              })
            end,
          },
          "dharmx/telescope-media.nvim",
          "nvim-telescope/telescope-symbols.nvim",
        },
        config = function()
          local builtin = require("telescope.builtin")
          local actions = require("telescope.actions")

          vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files using Telescope" })
          vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep using Telescope" })
          vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "List open buffers using Telescope" })
          vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Search help tags using Telescope" })
          vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Show keymaps using Telescope" })
          vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Open recently opened files using Telescope" })

          require("telescope").setup({
            defaults = {
              -- layout_strategy = "vertical",
              path_display = {
                filename_first = {
                  reverse_directories = false,
                },
              },
              mappings = {
                i = {
                  ["<C-j>"] = actions.move_selection_next,
                  ["<C-k>"] = actions.move_selection_previous,
                  ["<esc>"] = actions.close,
                },
                n = {
                  ["j"] = actions.move_selection_next,
                  ["k"] = actions.move_selection_previous,
                },
              },
            },
          })
        end,
      },
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
