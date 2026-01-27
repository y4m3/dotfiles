return {
  {
    "TaDaa/vimade",
    -- Only enable in tmux environment
    cond = function()
      return vim.env.TMUX ~= nil and vim.env.TMUX ~= ""
    end,
    event = "VeryLazy",
    opts = {
      ncmode = "buffers",
      fadelevel = 0.4,
      tint = {
        fg = { rgb = { 86, 95, 137 }, intensity = 0.5 },  -- #565f89
        bg = { rgb = { 21, 22, 30 }, intensity = 0.3 },   -- #15161e
      },
      enablefocusfading = true,
    },
  },
}
