return {
  {
    "smoka7/hop.nvim",
    version = "*",
    opts = {
      keys = "etovxqpdygfblzhckisuran",
    },
    keys = {
      {
        "<Leader>s",
        function()
          require("hop").hint_char1()
        end,
        desc = "Hop to any character in the visible buffer",
      },
      {
        "<Leader>j",
        function()
          require("hop").hint_lines({ direction = require("hop.hint").HintDirection.AFTER_CURSOR })
        end,
        desc = "Hop to a line below the cursor",
      },
      {
        "<Leader>k",
        function()
          require("hop").hint_lines({ direction = require("hop.hint").HintDirection.BEFORE_CURSOR })
        end,
        desc = "Hop to a line above the cursor",
      },
      {
        "<Leader>w",
        function()
          require("hop").hint_words()
        end,
        desc = "Hop to a word in the visible buffer",
      },
    },
    config = true,
  },
}
