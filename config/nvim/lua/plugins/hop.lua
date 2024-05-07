return {
  {
    "smoka7/hop.nvim",
    config = function()
      require("hop").setup({
        keys = "asdfghjkl;vbnrtyu",
      })
    end,
    keys = function()
      return {
        {
          "<Leader>s",
          desc = "Hop to any character in the visible buffer",
          function()
            require("hop").hint_char1()
          end,
        },
        {
          "<Leader>j",
          desc = "Hop to a line below the cursor",
          function()
            require("hop").hint_lines({
              direction = require("hop.hint").HintDirection.AFTER_CURSOR,
            })
          end,
        },
        {
          "<Leader>k",
          desc = "Hop to a line above the cursor",
          function()
            require("hop").hint_lines({
              direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
            })
          end,
        },
        {
          "<Leader>w",
          desc = "Hop to a word in the visible buffer",
          function()
            require("hop").hint_words()
          end,
        },
      }
    end,
  },
}
