-- Options are automatically loaded before lazy.nvim startup
-- Default options: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

-- Clipboard: vim.g.clipboard is set in init.lua (must be before provider loads)
opt.clipboard = "unnamedplus"

-- Japanese encoding support (from existing vimrc)
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.fileencodings = "utf-8,iso-2022-jp,euc-jp,cp932"
-- Line ending settings (prefer LF for new files)
opt.fileformat = "unix"
opt.fileformats = "unix,dos"

-- Matching brackets highlight timing
opt.matchtime = 1

-- Natural line breaking for Japanese text
opt.formatoptions:append("mM")

-- Properly join lines containing Japanese text
opt.joinspaces = false

-- Keep some lines visible above/below cursor when scrolling
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Persistent undo history
opt.undofile = true
opt.undolevels = 10000

-- Line wrapping
opt.wrap = true
opt.linebreak = true

-- Cursor blink in all modes (note: may not work in all terminals)
opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,a:blinkwait700-blinkon400-blinkoff400"

-- Better diff algorithm for Japanese text
opt.diffopt:append({ "algorithm:histogram", "indent-heuristic" })

-- Visible whitespace characters
opt.list = true
opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
  extends = "›",
  precedes = "‹",
}

-- Hide statusline (bufferline handles the tabline)
opt.laststatus = 0

-- WSL: use wslview for opening URLs
if vim.fn.has("wsl") == 1 then
  vim.g.netrw_browsex_viewer = "wslview"
  vim.ui.open = function(path, opts)
    vim.fn.jobstart({ "wslview", path }, { detach = true })
  end
end

-- Windows: use pwsh (PowerShell 7+) for terminal, fallback to powershell 5
-- Requires full shell configuration for termopen() compatibility
-- See: https://github.com/neovim/neovim/issues/15634
if vim.fn.has("win32") == 1 then
  vim.o.shelltemp = false
  local shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command "
    .. "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();"
    .. "$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
  vim.o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  vim.o.shellquote = ""
  vim.o.shellxquote = ""
  if vim.fn.executable("pwsh") == 1 then
    vim.o.shell = "pwsh"
    shellcmdflag = shellcmdflag .. "$PSStyle.OutputRendering = 'PlainText';"
  else
    vim.o.shell = "powershell"
  end
  vim.o.shellcmdflag = shellcmdflag
end
