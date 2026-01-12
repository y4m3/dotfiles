return {
  {
    "yukimemi/silentsaver.vim",
    dependencies = { "vim-denops/denops.vim" },
    event = "VeryLazy",
    config = function()
      vim.g.silentsaver_dir = vim.fn.expand("~/.cache/silentsaver")
    end,
  },
}
