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

-- statusline非表示（bufferlineがタブラインを担当）
opt.laststatus = 0

-- WSL: use wslview for opening URLs
if vim.fn.has("wsl") == 1 then
  vim.g.netrw_browsex_viewer = "wslview"
  vim.ui.open = function(url)
    vim.fn.jobstart({ "wslview", url }, { detach = true })
  end
end
