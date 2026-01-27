return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = "markdown",
    cond = function()
      return vim.env.OBSIDIAN_VAULTS ~= nil
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>o", group = "obsidian" },
      { "<leader>on", "<cmd>ObsidianNew<CR>", desc = "New note" },
      { "<leader>ot", "<cmd>ObsidianNewFromTemplate<CR>", desc = "New from template" },
      { "<leader>os", "<cmd>ObsidianSearch<CR>", desc = "Search" },
      { "<leader>ob", "<cmd>ObsidianBacklinks<CR>", desc = "Backlinks" },
      { "<leader>ow", "<cmd>ObsidianWorkspace<CR>", desc = "Workspace" },
      { "<leader>ol", "<cmd>ObsidianLinks<CR>", desc = "Links" },
      { "<leader>oc", "<cmd>ObsidianToggleCheckbox<CR>", desc = "Toggle checkbox" },
    },
    opts = function()
      local vaults_str = vim.env.OBSIDIAN_VAULTS
      local workspaces = {}

      if not vaults_str then
        return {}
      end

      for vault_path in string.gmatch(vaults_str, "[^,]+") do
        vault_path = vim.trim(vault_path)
        if vault_path ~= "" then
          local vault_name = vim.fn.fnamemodify(vault_path, ":t")
          table.insert(workspaces, { name = vault_name, path = vault_path })
        end
      end

      return {
        workspaces = workspaces,

        note_id_func = function(title)
          return os.date("%Y%m%d%H%M%S")
        end,

        wiki_link_func = function(opts)
          if opts.label ~= opts.path then
            return string.format("[[%s|%s]]", opts.path, opts.label)
          else
            return string.format("[[%s]]", opts.path)
          end
        end,

        follow_url_func = function(url)
          local cmd
          if vim.fn.has("win32") == 1 then
            cmd = { "rundll32", "url.dll,FileProtocolHandler", url }
          elseif vim.fn.has("wsl") == 1 then
            cmd = { "wslview", url }
          else
            cmd = { "xdg-open", url }
          end
          vim.fn.jobstart(cmd, { detach = true })
        end,

        templates = {
          folder = "Templates/nvim",
          date_format = "%Y-%m-%d",
          time_format = "%H:%M",
          substitutions = {
            uid = function()
              return os.date("%Y%m%d%H%M%S")
            end,
            created_datetime = function()
              return os.date("%Y-%m-%d %H:%M:%S")
            end,
          },
        },

        new_notes_location = "notes_subdir",
        notes_subdir = "00_Fleeting",

        callbacks = {
          enter_note = function(_, note)
            vim.keymap.set("n", "gf", "<cmd>ObsidianFollowLink<CR>", { buffer = true })
            vim.keymap.set("n", "<CR>", "<cmd>ObsidianFollowLink<CR>", { buffer = true })
          end,
        },

        checkbox = {
          order = { " ", "x" },
        },

        completion = {
          nvim_cmp = false,
          blink = true,
        },

        picker = {
          name = "snacks.pick",
        },

        ui = {
          enable = false,
        },

        attachments = {
          img_folder = "Attachments",
        },

        preferred_link_style = "wiki",
      }
    end,
  },
}
