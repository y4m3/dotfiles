-- lazy.nvim loads this file before it starts up. LazyVim defaults:
-- https://www.lazyvim.org/configuration/general

-- LazyVim uses none of the remote-plugin providers. Disable them so
-- checkhealth stays quiet on both platforms.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- LazyVim sets `clipboard=unnamedplus`, then stashes and clears it until the
-- VeryLazy event (~150ms after startup) so a slow clipboard tool cannot hold
-- up startup. A yank in that window (open a file, hit yy straight away) lands
-- in the unnamed register only and never reaches the system clipboard, so set
-- it on UIEnter (~10ms) instead. It belongs here and not in autocmds.lua:
-- that file loads on VeryLazy, which lazy.nvim fires from its own UIEnter
-- handler, so an UIEnter autocmd registered there never runs. Same
-- SSH_CONNECTION guard LazyVim uses, to leave the OSC 52 fallback alone.
if not vim.env.SSH_CONNECTION then
  vim.api.nvim_create_autocmd("UIEnter", {
    once = true,
    callback = function()
      vim.opt.clipboard = "unnamedplus"
    end,
  })
end

-- :Dump [messages] rescues a buffer, or the :messages history, to a file.
-- A file write is binary-safe. The clipboard provider is not: it rejects
-- invalid UTF-8, for example checkhealth output on Japanese Windows. It
-- lives in options.lua, not autocmds.lua, so it also exists for commands
-- passed on the CLI (autocmds.lua loads on VeryLazy, too late for those).
vim.api.nvim_create_user_command("Dump", function(opts)
  local path = vim.fn.expand("~/nvim-dump.txt")
  local lines
  if opts.args == "messages" then
    lines = vim.split(vim.fn.execute("messages"), "\n")
  else
    lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  end
  vim.fn.writefile(lines, path)
  vim.notify("Dumped to " .. path)
end, {
  nargs = "?",
  complete = function()
    return { "messages" }
  end,
})
