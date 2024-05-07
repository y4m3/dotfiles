vim.cmd("filetype plugin on")
vim.cmd("filetype indent on")

local indent_settings = {
  python = {
    sw = 4,
    sts = 4,
    ts = 4,
    et = true,
  },
  lua = {
    sw = 2,
    sts = 2,
    ts = 2,
    et = true,
  },
  markdown = {
    sw = 4,
    sts = 4,
    ts = 4,
    et = true,
  },
  telekasten = {
    sw = 4,
    sts = 4,
    ts = 4,
    et = true,
  },
}

local function set_indent_settings()
  local filetype = vim.bo.filetype
  if indent_settings[filetype] then
    for k, v in pairs(indent_settings[filetype]) do
      vim.bo[k] = v
    end
  end
end

vim.api.nvim_create_autocmd("FileType", {
  callback = set_indent_settings,
})

-- python ruler
vim.cmd([[
  augroup pythonRuler
    autocmd!
    autocmd FileType python set colorcolumn=88
  augroup end
]])
