if not vim.g.vscode then
  return {
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
      },
      opts = {
        close_if_last_window = true,
        source_selector = {
          winbar = true,
          statusline = true,
        },
        window = {
          width = 40,
          position = "right",
        },
        filesystem = {
          follow_current_file = {
            enabled = false,
          },
          hijack_netrw_behavior = "open_current",
          use_libuv_file_watcher = true,
          filtered_items = {
            visible = false,
            show_hidden_count = true,
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          never_show = { ".git", ".DS_Store", ".history" },
          commands = {
            delete = function(state)
              local inputs = require("neo-tree.ui.inputs")
              local path = state.tree:get_node().path
              local msg = "Are you sure you want to trash " .. path
              inputs.confirm(msg, function(confirmed)
                if not confirmed then
                  return
                end
                vim.fn.system({ "trash", vim.fn.fnameescape(path) })
                require("neo-tree.sources.manager").refresh(state.name)
              end)
            end,
            delete_visual = function(state, selected_nodes)
              local inputs = require("neo-tree.ui.inputs")
              local count = #selected_nodes
              local msg = "Are you sure you want to trash " .. count .. " files?"
              inputs.confirm(msg, function(confirmed)
                if not confirmed then
                  return
                end
                for _, node in ipairs(selected_nodes) do
                  vim.fn.system({ "trash", vim.fn.fnameescape(node.path) })
                end
                require("neo-tree.sources.manager").refresh(state.name)
              end)
            end,
          },
        },
      },
      config = function(_, opts)
        require("neo-tree").setup(opts)
      end,
      keys = {
        {
          "<C-space><C-e>",
          function()
            require("neo-tree.command").execute({ toggle = true })
          end,
          desc = "Toggle Neo Tree",
        },
      },
    },
  }
else
  return {}
end
