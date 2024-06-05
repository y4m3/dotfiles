local function map(mode, lhs, rhs, opts)
  -- Create a table for default options
  local options = {
    noremap = true,
    silent = true,
  }
  -- If opts are provided, extend the default options with the given opts
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  -- Set the keymap using the provided mode, lhs, rhs, and options
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Set the leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Map "jk" in insert mode to escape
map("i", "jk", "<ESC>", {
  desc = "Exit insert mode",
})

-- Map "x" in normal mode to delete character without yanking
map("n", "x", '"_x', {
  desc = "Delete character without yanking",
})

-- Map "j" and "k" in normal mode to move vertically by visual lines
if not vim.g.vscode then
  map("n", "j", "gj", {
    desc = "Move down by visual lines",
  })
  map("n", "k", "gk", {
    desc = "Move up by visual lines",
  })
end

-- Map Ctrl+h/j/k/l in normal mode to navigate between windows
map("n", "<C-h>", "<C-w>h", {
  desc = "Navigate to left window",
})
map("n", "<C-j>", "<C-w>j", {
  desc = "Navigate to below window",
})
map("n", "<C-k>", "<C-w>k", {
  desc = "Navigate to above window",
})
map("n", "<C-l>", "<C-w>l", {
  desc = "Navigate to right window",
})

-- Move to previous/next tab
map("n", "<A-,>", ":tabprevious<CR>", {
  desc = "Go to previous tab",
})
map("n", "<A-.>", ":tabnext<CR>", {
  desc = "Go to next tab",
})

-- Move to previous/next buffer
map("n", "<A-h>", "<Cmd>BufferPrevious<CR>", {
  desc = "Go to previous buffer",
})
map("n", "<A-l>", "<Cmd>BufferNext<CR>", {
  desc = "Go to next buffer",
})

map("n", "<A-x>", "<Cmd>BufferClose<CR>", {
  desc = "Close buffer",
})

-- Map "ss" in normal mode to split window horizontally and switch to new window
map("n", "ss", ":split<Return><C-w>w", {
  desc = "Split window horizontally",
})
-- Map "sv" in normal mode to split window vertically and switch to new window
map("n", "sv", ":vsplit<Return><C-w>w", {
  desc = "Split window vertically",
})

-- Map Space+h in normal mode to move to the first non-blank character of the line
map("n", "<Space>h", "^", {
  desc = "Move to the first non-blank character",
})
-- Map Space+l in normal mode to move to the end of the line
map("n", "<Space>l", "$", {
  desc = "Move to the end of the line",
})

-- Map ESC and ESC in normal mode to clear search highlights
map("n", "<Esc><Esc>", ":nohlsearch<CR>", {
  desc = "Clear search highlights",
})

-- only for vscode-neovim
if vim.g.vscode then
  local vscode = require("vscode-neovim")
  local mappings = {
    up = "k",
    down = "j",
    wrappedLineStart = "0",
    wrappedLineFirstNonWhitespaceCharacter = "^",
    wrappedLineEnd = "$",
  }

  local function moveCursor(to, select)
    return function()
      local mode = vim.api.nvim_get_mode()
      if mode.mode == "V" or mode.mode == "" then
        return mappings[to]
      end

      vscode.action("cursorMove", {
        args = {
          {
            to = to,
            by = "wrappedLine",
            value = vim.v.count1,
            select = select,
          },
        },
      })
      return "<Ignore>"
    end
  end

  vim.keymap.set("n", "k", moveCursor("up"), {
    expr = true,
  })
  vim.keymap.set("n", "j", moveCursor("down"), {
    expr = true,
  })
end
