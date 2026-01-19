-- Helper: Get SKK dictionary path based on OS
local function get_dict_path()
  if vim.fn.has("win32") == 1 then
    return vim.fn.expand("~/.local/share/skk/SKK-JISYO.L")
  else
    return vim.fn.expand("~/.nix-profile/share/skk/SKK-JISYO.L")
  end
end

-- Helper: Setup skkeleton configuration
local function setup_skkeleton()
  local dict_path = get_dict_path()
  local global_dicts = {}

  if vim.fn.filereadable(dict_path) == 1 then
    table.insert(global_dicts, dict_path)
  else
    vim.notify("SKK dictionary not found: " .. dict_path, vim.log.levels.WARN)
  end

  vim.fn["skkeleton#config"]({
    globalDictionaries = global_dicts,
    userDictionary = vim.fn.expand("~/.skk/skk-jisyo"),
    showCandidatesCount = 3,
    selectCandidateKeys = "asdfjkl",
    eggLikeNewline = true,
    markerHenkan = "",
    markerHenkanSelect = "",
  })

  -- S-Space to go back to previous candidate
  vim.fn["skkeleton#register_keymap"]("henkan", "<S-Space>", "henkanBackward")

  -- Ensure user dictionary directory exists
  vim.fn.mkdir(vim.fn.expand("~/.skk"), "p")
end

return {
  {
    "NI57721/skkeleton-henkan-highlight",
    dependencies = { "vim-skk/skkeleton" },
    config = function()
      vim.api.nvim_set_hl(0, "SkkeletonHenkan", { underline = true })
      vim.api.nvim_set_hl(0, "SkkeletonHenkanSelect", { underline = true })
    end,
  },
  {
    "delphinus/skkeleton_indicator.nvim",
    branch = "v2",
    dependencies = { "vim-skk/skkeleton" },
    opts = {
      alwaysShown = false,
      fadeOutMs = 0,
      eijiText = "A",
      hiraText = "あ",
      kataText = "ア",
      hankataText = "ｱ",
      zenkakuText = "Ａ",
      abbrevText = "ab",
    },
  },
  {
    "vim-skk/skkeleton",
    dependencies = { "vim-denops/denops.vim" },
    lazy = false,
    keys = {
      { "<C-j>", "<Plug>(skkeleton-toggle)", mode = { "i", "c" }, desc = "Toggle SKK" },
    },
    init = function()
      -- Add S-Space to mapped keys (must be set before skkeleton loads)
      vim.g["skkeleton#mapped_keys"] = { "<S-Space>" }
    end,
    config = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "skkeleton-initialize-pre",
        callback = setup_skkeleton,
      })

      -- Disable skkeleton on InsertLeave
      vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
          if vim.fn["skkeleton#is_enabled"]() == 1 then
            vim.fn["skkeleton#disable"]()
          end
        end,
      })
    end,
  },
}
