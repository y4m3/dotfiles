if not vim.g.vscode then
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
      opts = function()
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
          "ts_ls",
        }
        return {
          servers = servers,
          setup = function(server, config)
            if server == "lua_ls" then
              config.settings = {
                Lua = {
                  diagnostics = { globals = { "vim", "bufnr" } },
                  format = false,
                },
              }
            elseif server == "pylsp" then
              config.settings = {
                pylsp = {
                  plugins = {
                    ruff = { enabled = true },
                    pycodestyle = { enabled = false },
                    pyflakes = { enabled = false },
                    mccabe = { enabled = false },
                    autopep8 = { enabled = false },
                    yapf = { enabled = false },
                  },
                },
              }
            end
          end,
        }
      end,
      config = function(_, opts)
        require("mason").setup()
        require("mason-lspconfig").setup({
          ensure_installed = opts.servers,
          automatic_installation = true,
        })
        local lspconfig = require("lspconfig")
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        for _, server in ipairs(opts.servers) do
          local config = { capabilities = capabilities }
          opts.setup(server, config)
          lspconfig[server].setup(config)
        end

        -- format keymap
        vim.keymap.set("n", "<space>fm", function()
          vim.lsp.buf.format({ async = true })
        end, { noremap = true, desc = "Format current buffer" })

        -- format on save
        vim.api.nvim_create_autocmd("BufWritePre", {
          callback = function()
            vim.lsp.buf.format({ async = false })
          end,
        })
      end,
    },
    {
      "jay-babu/mason-null-ls.nvim",
      event = { "BufReadPre", "BufNewFile" },
      dependencies = { "williamboman/mason.nvim", "nvimtools/none-ls.nvim" },
      opts = {
        ensure_installed = {
          "diagnostic-languageserver",
          "markdownlint",
          "shellcheck",
          "shfmt",
          "sqlfluff",
          "stylua",
          "yamllint",
        },
        automatic_installation = true,
        automatic_setup = true,
        handlers = {
          function(source_name, source)
            if source_name == "sqlfluff" then
              source.disabled = true
            end
            return source
          end,
        },
      },
      config = function(_, opts)
        require("mason-null-ls").setup(opts)
      end,
    },
    {
      "nvimtools/none-ls.nvim",
      event = { "VeryLazy" },
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = function()
        local null_ls = require("null-ls")
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
        local markdownlint_config = find_markdownlint_config()
        return {
          sources = {
            null_ls.builtins.diagnostics.markdownlint.with({
              filetypes = { "markdown", "telekasten" },
              extra_args = markdownlint_config and { "--config", markdownlint_config } or {},
            }),
            null_ls.builtins.formatting.markdownlint,
            null_ls.builtins.formatting.shfmt.with({ extra_args = { "-i", "2", "-ci", "-bn" } }),
            null_ls.builtins.formatting.prettier.with({
              filetypes = {
                "javascript",
                "typescript",
                "vue",
                "css",
                "html",
                "json",
                "yaml",
                "graphql",
              },
            }),
            null_ls.builtins.formatting.stylua.with({
              extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
            }),
            null_ls.builtins.formatting.sqlfluff,
            null_ls.builtins.diagnostics.sqlfluff,
          },
        }
      end,
      config = function(_, opts)
        require("null-ls").setup(opts)
      end,
    },
  }
else
  return {}
end
