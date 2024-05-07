-- defalut: off
if not vim.g.vscode then
  return {
    -- 	"github/copilot.vim",
    -- 	lazy = false,
    -- 	event = { "BufReadPre", "BufNewFile" },
    -- 	config = function()
    -- 		vim.g.copilot_no_tab_map = true
    -- 		vim.keymap.set("i", "<C-l>", 'copilot#Accept("\\<CR>")', {
    -- 			expr = true,
    -- 			replace_keycodes = false,
    -- 		})
    -- 		vim.keymap.set("i", "<C-;>", 'copilot#Accept("\\<CR>")', {
    -- 			expr = true,
    -- 			replace_keycodes = false,
    -- 		})
    -- 		vim.keymap.set("i", "<C-j>", "<Plug>(copilot-next)")
    -- 		vim.keymap.set("i", "<C-k>", "<Plug>(copilot-previous)")
    -- 		vim.keymap.set("i", "<C-o>", "<Plug>(copilot-dismiss)")
    -- 		vim.keymap.set("i", "<C-s>", "<Plug>(copilot-suggest)")
    -- 	end,
  }
else
  return {}
end
