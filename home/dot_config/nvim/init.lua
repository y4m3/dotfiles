-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- ============================================================================
-- Clipboard Configuration
-- ============================================================================

-- WSL: Use OSC 52 (SSH sessions can't access Windows clipboard directly)
-- Paste: Use Ctrl+Shift+V (terminal paste)
if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = function() return { "" } end,
      ["*"] = function() return { "" } end,
    },
  }
end

-- Windows (native): Use win32yank
if vim.fn.has("win32") == 1 then
  vim.g.clipboard = {
    name = "win32yank",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }
end
