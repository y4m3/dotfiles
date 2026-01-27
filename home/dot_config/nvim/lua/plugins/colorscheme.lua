return {
  {
    "folke/tokyonight.nvim",
    opts = function(_, opts)
      opts.style = "night"
      -- Enable transparent background in tmux for window-style support
      opts.transparent = vim.env.TMUX ~= nil and vim.env.TMUX ~= ""
      return opts
    end,
  },
}
