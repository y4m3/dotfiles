-- Options are automatically loaded before lazy.nvim startup
-- Default options: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

-- Clipboard: vim.g.clipboard is set in init.lua (must be before provider loads)
opt.clipboard = "unnamedplus"

-- Japanese encoding support (from existing vimrc)
opt.fileencodings = "utf-8,iso-2022-jp,euc-jp,cp932"
opt.fileformats = "unix,dos,mac"

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
