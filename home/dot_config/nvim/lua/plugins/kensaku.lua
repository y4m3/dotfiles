return {
  -- Kensaku core
  {
    "lambdalisue/vim-kensaku",
    dependencies = { "vim-denops/denops.vim" },
    event = "VeryLazy",
  },
  -- :Kensaku command (rarely used, / search is preferred)
  {
    "lambdalisue/kensaku-command.vim",
    dependencies = { "lambdalisue/vim-kensaku" },
    cmd = "Kensaku",
  },
  -- Japanese search with /
  {
    "lambdalisue/kensaku-search.vim",
    dependencies = { "lambdalisue/vim-kensaku" },
    keys = {
      { "<CR>", "<Plug>(kensaku-search-replace)<CR>", mode = "c", desc = "Kensaku Search" },
    },
  },
}
