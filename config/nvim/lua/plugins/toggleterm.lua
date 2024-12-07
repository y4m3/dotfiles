if not vim.g.vscode then
  return {
    {
      "akinsho/toggleterm.nvim",
      version = "*",
      opts = {
        open_mapping = [[<C-Space><C-Space>]],
        shade_terminals = true,
        shading_factor = 2,
        direction = "float", -- 'horizontal', 'vertical', 'tab', 'float'
        float_opts = {
          border = "curved",
        },
      },
      keys = {
        {
          "<C-Space><C-Space>",
          desc = "Toggle the terminal window",
        },
      },
      config = true,
    },
  }
else
  return {}
end
