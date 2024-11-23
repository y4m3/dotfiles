if not vim.g.vscode then
  return {
    {
      "iamcco/markdown-preview.nvim",
      lazy = false,
      cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
      ft = { "markdown", "telekasten" },
      build = function()
        vim.fn["mkdp#util#install"]()
      end,
      config = function()
        vim.g.mkdp_filetypes = { "markdown", "telekasten" }
        vim.g.mkdp_auto_close = 0
      end,
    },
    {
      "mzlogin/vim-markdown-toc",
      config = function()
        vim.g.vmt_auto_update_on_save = 1
        vim.g.vmt_dont_insert_fence = 1
        vim.g.vmt_list_item_char = "-"
        vim.g.vmt_max_level = 3
      end,
    },
    {
      "ixru/nvim-markdown",
      config = function() end,
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      -- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
      -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
      dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
      ---@module 'render-markdown'
      ---@type render.md.UserConfig
      opts = {},
    },
  }
else
  return {}
end
