return {
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog", "MasonUpdate" },
    dependencies = {
      "mason-org/mason-registry",
      "neovim/nvim-lspconfig",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
    },

    config = function()
      local servers = {
        "bashls",
        "clangd",
        "cmake",
        "cssls",
        "docker_compose_language_service",
        "dockerls",
        "html",
        "jsonls",
        "lua_ls",
        "marksman",
        "pylsp",
        "ruff",
        "tsserver",
      }

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_installation = true,
      })

      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local function setup_server(server, config)
        config = config or {}
        config.capabilities = capabilities
        if server == "lua_ls" then
          config.settings = {
            Lua = {
              diagnostics = {
                globals = { "vim", "bufnr" },
              },
              format = false,
            },
          }
        elseif server == "pylsp" then
          -- https://github.com/astral-sh/ruff/blobsum/main/crates/ruff_server/docs/setup/NEOVIM.md
          config.settings = {
            pylsp = {
              plugins = {
                ruff = {
                  enabled = true,
                },
                pycodestyle = {
                  enabled = false,
                },
                pyflakes = {
                  enabled = false,
                },
                mccabe = {
                  enabled = false,
                },
                autopep8 = {
                  enabled = false,
                },
                yapf = {
                  enabled = false,
                },
              },
            },
          }
        end

        lspconfig[server].setup(config)
      end

      for _, server in pairs(servers) do
        setup_server(server)
      end

      -- format keymap
      vim.keymap.set("n", "<space>fm", function()
        vim.lsp.buf.format({
          async = true,
        })
      end, { noremap = true, desc = "Format current buffer" })

      -- format on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    config = function()
      require("mason-null-ls").setup({
        ensure_installed = {
          "diagnosticls",
          "markdownlint",
          "shellcheck",
          "shfmt",
          "sqlfluff",
          "stylua",
          "yamllint",
        },
        automatic_installation = true,
        automatic_setup = true,
        handlers = {},
      })
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    event = { "VeryLazy" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "jay-babu/mason-null-ls.nvim",
        dependencies = { "mason.nvim" },
      },
    },
    config = function()
      local null_ls = require("null-ls")
      local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

      local function find_markdownlint_config()
        local config_files = {
          ".markdownlint.json",
          "config/.markdownlint.json",
          vim.fn.expand("~/.config/.markdownlint.json"),
          vim.fn.expand("~/.markdownlint.json"),
        }

        for _, file in ipairs(config_files) do
          if vim.fn.filereadable(file) == 1 then
            return file
          end
        end

        return nil
      end

      local function get_markdownlint_config()
        local config_file = find_markdownlint_config()
        if config_file then
          return { "--config", config_file }
        end
        return {}
      end

      local markdownlint_settings = {
        filetypes = { "markdown", "telekasten" },
        extra_args = get_markdownlint_config,
      }

      local source_settings = {
        -- markdown
        null_ls.builtins.diagnostics.markdownlint.with({ markdownlint_settings }),
        null_ls.builtins.formatting.markdownlint.with({ markdownlint_settings }),

        -- shell
        null_ls.builtins.formatting.shfmt.with({ extra_args = { "-i", "2", "-ci", "-bn" } }),

        -- prettier
        null_ls.builtins.formatting.prettier.with({
          filetypes = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "vue",
            "css",
            "scss",
            "less",
            "html",
            "json",
            "jsonc",
            "yaml",
            "graphql",
            "handlebars",
          },
        }),

        -- lua
        null_ls.builtins.formatting.stylua.with({
          filetypes = { "lua" },
          extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
        }),
      }

      null_ls.setup({
        sources = source_settings,

        -- format on save
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = vim.api.nvim_get_current_buf(),
              callback = function()
                vim.lsp.buf.format({ async = false })
              end,
            })
          end
        end,
      })
    end,
  },
  {
    "nvimdev/lspsaga.nvim",
    branch = "main",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("lspsaga").setup({
        finder = {
          max_height = 0.6,
          default = "tyd+ref+imp+def",
          keys = {
            toggle_or_open = "<CR>",
            vsplit = "v",
            split = "s",
            tabnew = "t",
            tab = "T",
            quit = "q",
            close = "<Esc>",
          },
          methods = {
            tyd = "textDocument/typeDefinition",
          },
        },
        scroll_preview = {
          scroll_down = "<C-n>",
          scroll_up = "<C-p>",
        },
      })

      local keymap = vim.keymap.set
      keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "Show hover documentation (lspsaga)" })
      keymap("n", "gf", "<cmd>Lspsaga finder<CR>", { desc = "Find references (lspsaga)" })
      keymap("n", "gd", "<cmd>Lspsaga peek_definition<CR>", { desc = "Peek definition (lspsaga)" })
      keymap("n", "ga", "<cmd>Lspsaga code_action<CR>", { desc = "Code action (lspsaga)" })
      keymap("n", "gr", "<cmd>Lspsaga rename<CR>", { desc = "Rename symbol (lspsaga)" })
      keymap("n", "ge", "<cmd>Lspsaga show_line_diagnostics<CR>", { desc = "Show line diagnostics (lspsaga)" })
      keymap("n", "g[", "<cmd>Lspsaga diagnostic_jump_next<CR>", { desc = "Jump to next diagnostic (lspsaga)" })
      keymap("n", "g]", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { desc = "Jump to previous diagnostic (lspsaga)" })
      keymap(
        "t",
        "<C-d>",
        [[<C-\><C-n><cmd>Lspsaga close_floaterm<CR>]],
        { desc = "Close floating terminal (lspsaga)" }
      )
    end,
  },
  {
    "j-hui/fidget.nvim",
    config = function()
      require("fidget").setup({})
    end,
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      require("lsp_signature").setup(opts)
    end,
  },
}
