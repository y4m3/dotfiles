return {
  {
    "akinsho/bufferline.nvim",
    init = function()
      -- Always show tabline (bufferline manages this)
      vim.opt.showtabline = 2
    end,
    opts = {
      options = {
        always_show_bufferline = true,
      },
    },
  },
}
