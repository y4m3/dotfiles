return {
  {
    "yuki-yano/fuzzy-motion.vim",
    dependencies = {
      "vim-denops/denops.vim",
      "lambdalisue/vim-kensaku",
    },
    keys = {
      { "<Leader>j", "<cmd>FuzzyMotion<CR>", desc = "Fuzzy Motion (Japanese)" },
    },
    config = function()
      vim.g.fuzzy_motion_matchers = { "kensaku", "fzf" }
    end,
  },
}
