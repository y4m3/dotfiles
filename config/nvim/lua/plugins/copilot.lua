if not vim.g.vscode then
  return { -- {
    --   "github/copilot.vim",
    --   lazy = false,
    --   event = { "BufReadPre", "BufNewFile" },
    --   config = function()
    --     vim.g.copilot_no_tab_map = true
    --     vim.keymap.set("i", "<C-l>", 'copilot#Accept("\\<CR>")', {
    --       expr = true,
    --       replace_keycodes = false,
    --     })
    --     vim.keymap.set("i", "<C-;>", 'copilot#Accept("\\<CR>")', {
    --       expr = true,
    --       replace_keycodes = false,
    --     })
    --     vim.keymap.set("i", "<C-j>", "<Plug>(copilot-next)")
    --     vim.keymap.set("i", "<C-k>", "<Plug>(copilot-previous)")
    --     vim.keymap.set("i", "<C-o>", "<Plug>(copilot-dismiss)")
    --     vim.keymap.set("i", "<C-s>", "<Plug>(copilot-suggest)")
    --   end,
    -- },
    {
      "zbirenbaum/copilot.lua",
      cmd = "Copilot",
      event = { "InsertEnter", "CmdlineEnter" },
      config = function()
        require("copilot").setup({
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
        })
      end,
    },
    {
      "CopilotC-Nvim/CopilotChat.nvim",
      branch = "canary",
      dependencies = { "zbirenbaum/copilot.lua", "nvim-lua/plenary.nvim" },
      event = { "InsertEnter", "CmdlineEnter" },
      config = function()
        require("CopilotChat").setup({
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
              prompt = "/COPILOT_GENERATE There is a problem in this code. Rewrite the code to show it with the bug fixed.",
              mapping = "<leader>lf",
              description = "copilot: fix the code",
            },
            Optimize = {
              prompt = "/COPILOT_GENERATE Optimize the selected code to improve performance and readablilty.",
              mapping = "<leader>lo",
              description = "copilot: optimize the code",
            },
            Docs = {
              prompt = "/COPILOT_GENERATE Please add documentation comment for the selection.",
              mapping = "<leader>ld",
              description = "copilot: generate documentation for the code",
            },
            Tests = {
              prompt = "/COPILOT_GENERATE Please generate tests for my code.",
              mapping = "<leader>lt",
              description = "copilot: write tests for the code",
            },
            FixDiagnostic = {
              prompt = "Please assist with the following diagnostic issue in file:",
              mapping = "<leader>lx",
              selection = require("CopilotChat.select").diagnostics,
              description = "copilot: fix the diagnostic",
            },
            Commit = {
              prompt = "Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
              mapping = "<leader>lm",
              selection = require("CopilotChat.select").gitdiff,
              description = "copilot: commit the changes",
            },
            CommitStaged = {
              prompt = "Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
              mapping = "<leader>ls",
              selection = function(source)
                return require("CopilotChat.select").gitdiff(source, true)
              end,
              description = "copilot: commit the staged changes",
            },
          },
        })

        -- intergrate with telescope
        local function set_keymaps()
          local actions = require("CopilotChat.actions")
          require("CopilotChat.integrations.telescope").pick(actions.help_actions())
        end
        vim.keymap.set("n", "<leader>cch", set_keymaps, {
          desc = "CopilotChat - Help actions",
        })
        vim.keymap.set("v", "<leader>cch", set_keymaps)

        local function set_keymaps_prompt()
          local actions = require("CopilotChat.actions")
          require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
        end
        vim.keymap.set("n", "<leader>ccp", set_keymaps_prompt, {
          desc = "CopilotChat - Prompt actions",
        })
        vim.keymap.set("v", "<leader>ccp", set_keymaps_prompt)
      end,
    },
    {
      "zbirenbaum/copilot-cmp",
      event = { "InsertEnter", "CmdlineEnter" },
      config = function()
        require("copilot_cmp").setup({})
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

        local has_words_before = function()
          if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
            return false
          end
          local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
        end
        cmp.setup({
          ["<Tab>"] = vim.schedule_wrap(function(fallback)
            if cmp.visible() and has_words_before() then
              cmp.select_next_item({
                behavior = cmp.SelectBehavior.Select,
              })
            else
              fallback()
            end
          end),
        })
      end,
    },
  }
else
  return {}
end
