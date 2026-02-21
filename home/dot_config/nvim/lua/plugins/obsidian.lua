return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = "markdown",
    cond = function()
      local vaults_str = vim.env.OBSIDIAN_VAULTS
      return vaults_str ~= nil and vaults_str:match("[^,%s]") ~= nil
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>o", group = "obsidian" },
      { "<leader>on", "<cmd>Obsidian new<CR>", desc = "New note" },
      { "<leader>ot", "<cmd>Obsidian template<CR>", desc = "New from template" },
      { "<leader>os", "<cmd>Obsidian search<CR>", desc = "Search" },
      { "<leader>ob", "<cmd>Obsidian backlinks<CR>", desc = "Backlinks" },
      { "<leader>ow", "<cmd>Obsidian workspace<CR>", desc = "Workspace" },
      { "<leader>ol", "<cmd>Obsidian links<CR>", desc = "Links" },
      { "<leader>oc", "<cmd>Obsidian toggle_checkbox<CR>", desc = "Toggle checkbox" },
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

        legacy_commands = false,

        callbacks = {
          enter_note = function(_, note)
            vim.keymap.set("n", "gf", "<cmd>Obsidian follow_link<CR>", { buffer = true })
            vim.keymap.set("n", "<CR>", "<cmd>Obsidian follow_link<CR>", { buffer = true })
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
          folder = "Attachments",
        },

        preferred_link_style = "wiki",
      }
    end,
  },
}
