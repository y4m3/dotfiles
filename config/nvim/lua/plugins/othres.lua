return {
  { "dstein64/vim-startuptime" },
  {
    "windwp/nvim-autopairs",
    config = true,
  },
  {
    "numToStr/Comment.nvim",
    lazy = false,
    config = function()
      require("Comment").setup({
        padding = true,
        sticky = true,
        ignore = nil,
      })
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
    config = function()
      local highlight = {
        "CursorColumn",
        "Whitespace",
      }
      require("ibl").setup({
        indent = { highlight = highlight, char = "" },
        whitespace = {
          highlight = highlight,
          remove_blankline_trail = false,
        },
        scope = { enabled = false },
      })
    end,
  },
  {
    "folke/which-key.nvim",
    lazy = true,
    cmd = { "WhichKey" },
  },
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("alpha").setup(require("alpha.themes.startify").config)
    end,
  },
  {
    "bun913/min-todo.vim",
    config = function()
      -- toggle task status in normal mode
      vim.api.nvim_set_keymap("n", "<C-c>", ":ToggleTask<CR>", { noremap = true, silent = true })

      -- create new task in insert mode
      vim.api.nvim_set_keymap("i", "<C-c>", "<ESC>:CreateTask<CR>", { noremap = true, silent = true })

      -- open todo.md
      vim.api.nvim_set_keymap("n", "<Leader>t", ":tabe ~/todo.md<CR>", { noremap = true, silent = true })
    end,
  },
}
