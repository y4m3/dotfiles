if not vim.g.vscode then
  local function apply_vim_g(opts)
    for key, value in pairs(opts) do
      vim.g[key] = value
    end
  end

  return {
    {
      "iamcco/markdown-preview.nvim",
      lazy = false,
      cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
      ft = { "markdown", "telekasten" },
      build = "cd app && npm install",
      opts = {
        mkdp_filetypes = { "markdown", "telekasten" },
        mkdp_auto_close = 0,
      },
      config = function(_, opts)
        apply_vim_g(opts)
      end,
    },
    {
      "mzlogin/vim-markdown-toc",
      opts = {
        vmt_auto_update_on_save = 1,
        vmt_dont_insert_fence = 1,
        vmt_list_item_char = "-",
        vmt_max_level = 3,
      },
      config = function(_, opts)
        apply_vim_g(opts)
      end,
    },
    {
      "ixru/nvim-markdown",
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    },
  }
else
  return {}
end
