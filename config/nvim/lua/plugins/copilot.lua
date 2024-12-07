if not vim.g.vscode then
  return {
    -- Copilot Vim Plugin
    -- {
    --   "github/copilot.vim",
    --   lazy = false,
    --   event = { "BufReadPre", "BufNewFile" },
    --   opts = {
    --     keymaps = {
    --       accept = { "<C-l>", "<C-;>" },
    --       next = "<C-j>",
    --       prev = "<C-k>",
    --       dismiss = "<C-o>",
    --       suggest = "<C-s>",
    --     },
    --   },
    --   config = function(_, opts)
    --     vim.g.copilot_no_tab_map = true
    --     for name, key in pairs(opts.keymaps) do
    --       if name == "accept" then
    --         for _, k in ipairs(key) do
    --           vim.keymap.set("i", k, 'copilot#Accept("\\<CR>")', {
    --             expr = true,
    --             replace_keycodes = false,
    --           })
    --         end
    --       else
    --         vim.keymap.set("i", key, "<Plug>(copilot-" .. name .. ")")
    --       end
    --     end
    --   end,
    -- },
    -- Copilot Lua Plugin
    {
      "zbirenbaum/copilot.lua",
      cmd = "Copilot",
      event = { "InsertEnter", "CmdlineEnter" },
      opts = {
        panel = {
          enable = true,
          auto_refresh = true,
          open = "<C-CR>",
        },
        suggestion = {
          enable = true,
          auto_trigger = true,
          keymap = {
            accept = "<C-l>",
            next = "<C-n>",
            prev = "<C-p>",
            dismiss = "<ESC>",
          },
        },
        filetypes = {
          markdown = true,
          gitcommit = true,
          gitrebase = true,
        },
      },
      config = function(_, opts)
        require("copilot").setup(opts)
      end,
    },
    -- Copilot Chat Plugin
    {
      "CopilotC-Nvim/CopilotChat.nvim",
      dependencies = { { "zbirenbaum/copilot.lua" }, { "nvim-lua/plenary.nvim", branch = "master" } },
      event = { "InsertEnter", "CmdlineEnter" },
      opts = {
        show_help = true,
        prompts = {
          Explain = {
            prompt = "/COPILOT_EXPLAIN Write an explanation for the active selection as paragraphs of text.",
            mapping = "<leader>le",
            description = "copilot: explain the code",
          },
          Review = {
            prompt = "/COPILOT_REVIEW Review the selected code.",
            mapping = "<leader>lr",
            description = "copilot: review the code",
          },
          Fix = {
            prompt = "/COPILOT_GENERATE Rewrite the code to show it with the bug fixed.",
            mapping = "<leader>lf",
            description = "copilot: fix the code",
          },
          Optimize = {
            prompt = "/COPILOT_GENERATE Optimize the selected code to improve performance and readability.",
            mapping = "<leader>lo",
            description = "copilot: optimize the code",
          },
        },
      },
      config = function(_, opts)
        require("CopilotChat").setup(opts)

        -- Telescope Keymaps
        vim.keymap.set("n", "<leader>cch", function()
          local actions = require("CopilotChat.actions")
          require("CopilotChat.integrations.telescope").pick(actions.help_actions())
        end, { desc = "CopilotChat - Help actions" })
      end,
    },
    -- Copilot Completion Integration for nvim-cmp
    {
      "zbirenbaum/copilot-cmp",
      event = { "InsertEnter", "CmdlineEnter" },
      opts = {},
      config = function(_, opts)
        require("copilot_cmp").setup(opts)
        local cmp = require("cmp")
        cmp.setup.buffer({
          sources = { {
            name = "copilot",
            group_index = 2,
          } },
        })

        require("lspkind").init({
          symbol_map = {
            Copilot = "",
          },
        })

        vim.api.nvim_set_hl(0, "CmpItemKindCopilot", {
          fg = "#6CC644",
        })
      end,
    },
  }
else
  return {}
end
