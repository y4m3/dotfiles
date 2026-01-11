-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- Natural movement for wrapped lines (from existing vimrc)
vim.keymap.set({ "n", "v" }, "j", "gj", { desc = "Move down (wrapped)" })
vim.keymap.set({ "n", "v" }, "k", "gk", { desc = "Move up (wrapped)" })

-- Exit insert mode with jj, jk (alternative to Escape key)
map("i", "jj", "<Esc>", { desc = "Exit insert mode" })
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Use ; to enter command mode
map("n", ";", ":", { desc = "Command mode" })
map("v", ";", ":", { desc = "Command mode" })

-- Exit terminal mode with double Esc
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
