-- Additional Tree-sitter parsers beyond LazyVim defaults.
-- This file only adds parsers not included in the default set.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "latex" },
    },
  },
}
