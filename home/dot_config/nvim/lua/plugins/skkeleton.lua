return {
  -- Main SKK input method
  {
    "vim-skk/skkeleton",
    dependencies = { "vim-denops/denops.vim" },
    event = { "InsertEnter", "CmdlineEnter" },
    keys = {
      { "<C-j>", "<Plug>(skkeleton-toggle)", mode = { "i", "c" }, desc = "Toggle SKK" },
    },
    config = function()
      vim.fn["skkeleton#config"]({
        globalDictionaries = {
          vim.fn.expand("~/.nix-profile/share/skk/SKK-JISYO.L"),
        },
        userDictionary = vim.fn.expand("~/.skk/skk-jisyo"),
      })

      -- Create user dictionary directory
      vim.fn.mkdir(vim.fn.expand("~/.skk"), "p")
    end,
  },
  -- Highlight henkan candidates
  {
    "NI57721/skkeleton-henkan-highlight",
    dependencies = { "vim-skk/skkeleton" },
    event = "InsertEnter",
  },
  -- snacks.nvim integration
  {
    "urugus/skkeleton-snacks",
    dependencies = {
      "vim-skk/skkeleton",
      "folke/snacks.nvim",
    },
    event = "VeryLazy",
  },
}
