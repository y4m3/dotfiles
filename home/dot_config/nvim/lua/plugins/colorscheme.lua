return {
  {
    "folke/tokyonight.nvim",
    opts = function(_, opts)
      opts.style = "night"
      -- tmux上では背景を透過してtmuxのwindow-styleを有効化
      opts.transparent = vim.env.TMUX ~= nil
      return opts
    end,
  },
}
