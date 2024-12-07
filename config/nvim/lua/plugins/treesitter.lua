if not vim.g.vscode then
  return {
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      opts = {
        ensure_installed = {
          "bash",
          "css",
          "diff",
          "dockerfile",
          "git_config",
          "gitcommit",
          "gitignore",
          "html",
          "javascript",
          "json",
          "lua",
          "markdown",
          "markdown_inline",
          "python",
          "regex",
          "toml",
          "vim",
          "yaml",
        },
        highlight = {
          enable = true, -- Enable syntax highlighting
        },
        indent = {
          enable = true, -- Enable automatic indentation
        },
        playground = {
          enable = true, -- Enable the Treesitter playground for query debugging
          disable = {},
          updatetime = 25, -- Update time for the playground (in ms)
          persist_queries = false, -- Don't persist queries across sessions
        },
        query_linter = {
          enable = true, -- Enable linting for Treesitter queries
          use_virtual_text = true,
          lint_events = { "BufWrite", "CursorHold" },
        },
      },
      config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
      end,
    },
  }
else
  return {}
end
