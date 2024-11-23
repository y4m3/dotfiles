if not vim.g.vscode then
  return {
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = {
            "bash",
            "css",
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
            enable = true,
          },
          indent = {
            enable = true,
          },
          playground = {
            enable = true,
            disable = {},
            updatetime = 25,
            persist_queries = false,
          },
          query_linter = {
            enable = true,
            use_virtual_text = true,
            lint_events = { "BufWrite", "CursorHold" },
          },
        })
      end,
    },
  }
else
  return {}
end
