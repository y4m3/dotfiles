-- Neovide-specific settings
-- Only loaded when running in Neovide (checked in init.lua)

-- ============================================================================
-- Working Directory
-- ============================================================================
-- Start in home directory when launched without arguments (e.g., from shortcut)
if vim.fn.argc() == 0 then
  vim.api.nvim_set_current_dir(vim.fn.expand("~"))
end

-- ============================================================================
-- Font Settings
-- ============================================================================
vim.o.guifont = "UDEV Gothic 35NFLG:h11"
vim.o.linespace = 2

-- ============================================================================
-- Scale Factor
-- ============================================================================
vim.g.neovide_scale_factor = 1.0

-- Scale adjustment keymaps
vim.keymap.set("n", "<C-=>", function()
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 1.1
end, { desc = "Neovide: increase scale" })

vim.keymap.set("n", "<C-->", function()
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor / 1.1
end, { desc = "Neovide: decrease scale" })

vim.keymap.set("n", "<C-0>", function()
  vim.g.neovide_scale_factor = 1.0
end, { desc = "Neovide: reset scale" })

-- ============================================================================
-- Cursor Animation
-- ============================================================================
vim.g.neovide_cursor_animation_length = 0.08
vim.g.neovide_cursor_trail_size = 0.25
vim.g.neovide_cursor_vfx_mode = "pixiedust"

-- ============================================================================
-- Scroll Animation
-- ============================================================================
vim.g.neovide_scroll_animation_length = 0.15

-- ============================================================================
-- Floating Window Effects
-- ============================================================================
vim.g.neovide_floating_shadow = true
vim.g.neovide_floating_blur_amount_x = 2.0
vim.g.neovide_floating_blur_amount_y = 2.0

-- ============================================================================
-- Fullscreen Toggle
-- ============================================================================
vim.keymap.set("n", "<F11>", function()
  vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
end, { desc = "Neovide: toggle fullscreen" })

-- ============================================================================
-- macOS Support (for future use)
-- ============================================================================
if vim.fn.has("macunix") == 1 then
  vim.g.neovide_input_macos_option_key_is_meta = "both"
end
