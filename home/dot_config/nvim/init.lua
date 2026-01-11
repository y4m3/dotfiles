-- ============================================================================
-- Clipboard Configuration for WSL
-- ============================================================================
-- WHY OSC 52 instead of win32yank.exe?
--
-- WezTerm connects to WSL via SSH domain (`connection = "connect"`).
-- SSH sessions are isolated from the Windows desktop session, so
-- win32yank.exe cannot access the Windows clipboard.
--
-- Connection type differences:
--   SSH (`connect`)  → Isolated session → win32yank.exe ❌
--   wsl.exe (`local`) → Inherited session → win32yank.exe ✅
--
-- OSC 52 escape sequences work because they go through the terminal,
-- which then handles clipboard operations on the Windows side.
--
-- For paste: Use Ctrl+Shift+V (terminal paste) since OSC 52 paste
-- is not widely supported for security reasons.
-- ============================================================================
if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      -- OSC 52 paste is not supported by most terminals for security.
      -- Use Ctrl+Shift+V for paste, or switch to wsl.exe connection.
      ["+"] = function() return { "" } end,
      ["*"] = function() return { "" } end,
    },
  }
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
