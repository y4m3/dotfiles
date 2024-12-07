if not vim.g.vscode then
  return {
    -- Gitsigns Plugin
    {
      "lewis6991/gitsigns.nvim",
      opts = {
        signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
        numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir = {
          interval = 1000,
          follow_files = true,
        },
        attach_to_untracked = true,
        current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
          delay = 1000,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000, -- Disable if file is longer than this (in lines)
        preview_config = {
          -- Options passed to nvim_open_win
          border = "single",
          style = "minimal",
          relative = "cursor",
          row = 0,
          col = 1,
        },
      },
      config = function(_, opts)
        require("gitsigns").setup(opts)
        -- Set highlight links for Gitsigns
        local function set_highlight_links(highlights)
          for _, hl in ipairs(highlights) do
            vim.api.nvim_set_hl(0, hl, { link = hl })
          end
        end
        set_highlight_links({
          "GitSignsAdd",
          "GitSignsAddNr",
          "GitSignsAddLn",
          "GitSignsChange",
          "GitSignsChangeNr",
          "GitSignsChangeLn",
          "GitSignsDelete",
          "GitSignsDeleteNr",
          "GitSignsDeleteLn",
        })
      end,
    },
    -- Project Plugin
    {
      "ahmedkhalf/project.nvim",
      dependencies = { "nvim-telescope/telescope.nvim", "nvim-neo-tree/neo-tree.nvim" },
      opts = {},
      config = function(_, opts)
        require("project_nvim").setup(opts)
        require("telescope").load_extension("projects")
        vim.keymap.set("n", "<leader>fp", "<CMD>Telescope projects<CR>", { desc = "Open recently opened git project" })
      end,
    },
  }
else
  return {}
end
