-- Authenticate git requests to GitHub (raises rate limit 60 -> 5000/hr)
-- Fetches token from gh CLI and injects via git http.extraheader
if vim.fn.executable("gh") == 1 then
  local token = vim.fn.system("gh auth token"):gsub("%s+$", "")
  if vim.v.shell_error == 0 and token ~= "" then
    vim.env.GITHUB_TOKEN = token
    local encoded = vim.base64.encode("x-access-token:" .. token)
    vim.env.GIT_CONFIG_COUNT = "1"
    vim.env.GIT_CONFIG_KEY_0 = "http.https://github.com/.extraheader"
    vim.env.GIT_CONFIG_VALUE_0 = "Authorization: basic " .. encoded
  end
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- ============================================================================
-- Clipboard Configuration
-- ============================================================================

-- WSL: clipboard configuration depends on terminal multiplexer
if vim.fn.has("wsl") == 1 then
  -- TMUX: win32yank for both copy and paste (OSC 52 requires DCS wrapper)
  if vim.env.TMUX then
    vim.g.clipboard = {
      name = "win32yank (tmux)",
      copy = {
        ["+"] = "win32yank.exe -i --crlf",
        ["*"] = "win32yank.exe -i --crlf",
      },
      paste = {
        ["+"] = "win32yank.exe -o --lf",
        ["*"] = "win32yank.exe -o --lf",
      },
    }
  -- Non-TMUX (zellij etc): OSC 52 for copy, win32yank for paste
  else
    vim.g.clipboard = {
      name = "OSC 52 + win32yank",
      copy = {
        ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
        ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
      },
      paste = {
        ["+"] = "win32yank.exe -o --lf",
        ["*"] = "win32yank.exe -o --lf",
      },
    }
  end
-- SSH (non-WSL): OSC 52 for both copy and paste (Wezterm supports OSC 52 paste)
elseif vim.env.SSH_CONNECTION then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
-- Windows (native): Use win32yank
elseif vim.fn.has("win32") == 1 then
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

-- ============================================================================
-- Neovide Configuration
-- ============================================================================
if vim.g.neovide then
  require("config.neovide")
end
