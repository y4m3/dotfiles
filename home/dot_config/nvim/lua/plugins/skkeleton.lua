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
      -- Determine dictionary path based on OS
      local dict_path
      if vim.fn.has("win32") == 1 then
        dict_path = vim.fn.expand("~/.local/share/skk/SKK-JISYO.L")
      else
        dict_path = vim.fn.expand("~/.nix-profile/share/skk/SKK-JISYO.L")
      end

      -- Check if dictionary exists
      local global_dicts = {}
      if vim.fn.filereadable(dict_path) == 1 then
        table.insert(global_dicts, dict_path)
      else
        vim.notify("SKK dictionary not found: " .. dict_path, vim.log.levels.WARN)
      end

      vim.fn["skkeleton#config"]({
        globalDictionaries = global_dicts,
        userDictionary = vim.fn.expand("~/.skk/skk-jisyo"),
      })

      -- Create user dictionary directory
      vim.fn.mkdir(vim.fn.expand("~/.skk"), "p")

      -- Track skkeleton state for blink.cmp integration
      vim.g.skkeleton_enabled = false

      vim.api.nvim_create_autocmd("User", {
        pattern = "skkeleton-enable-post",
        callback = function()
          vim.g.skkeleton_enabled = true
          local ok, blink = pcall(require, "blink.cmp")
          if ok and type(blink.hide) == "function" then
            pcall(blink.hide)
          end
        end,
        desc = "Track skkeleton enabled state",
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "skkeleton-disable-post",
        callback = function()
          vim.g.skkeleton_enabled = false
        end,
        desc = "Track skkeleton disabled state",
      })
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
