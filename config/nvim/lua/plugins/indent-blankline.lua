if not vim.g.vscode then
  return {
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      opts = {
        indent = {
          highlight = { "CursorColumn", "Whitespace" },
          char = "",
        },
        whitespace = {
          highlight = { "CursorColumn", "Whitespace" },
          remove_blankline_trail = false,
        },
        scope = { enabled = false },
      },
      config = function(_, opts)
        require("ibl").setup(opts)
      end,
    },
  }
else
  return {}
end
