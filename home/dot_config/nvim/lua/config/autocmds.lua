-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Markdown-specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "markdown.mdx" },
  callback = function()
    -- Disable autoformat (manual: markdownlint-cli2 "**/*.md")
    vim.b.autoformat = false
    -- Disable spell (Japanese gets wavy lines with default spell)
    vim.opt_local.spell = false
  end,
})

-- Prose-friendly settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "markdown.mdx", "text", "rst", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.showbreak = "↪ "
    vim.opt_local.textwidth = 0
  end,
})

-- Code files: no wrap
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "python", "sh", "bash", "typescript", "javascript", "go", "rust", "nix" },
  callback = function()
    vim.opt_local.wrap = false
  end,
})

-- Highlight fullwidth spaces (ideographic space U+3000)
-- Use WinEnter with window-local tracking to avoid duplicates
vim.api.nvim_create_autocmd({ "WinEnter", "VimEnter" }, {
  callback = function()
    if not vim.w.ideographic_space_match then
      vim.fn.matchadd("IdeographicSpace", "\u{3000}")
      vim.w.ideographic_space_match = true
    end
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "IdeographicSpace", { underline = true, sp = "Red" })
  end,
})

-- Set initial highlight (for current colorscheme)
vim.api.nvim_set_hl(0, "IdeographicSpace", { underline = true, sp = "Red" })
