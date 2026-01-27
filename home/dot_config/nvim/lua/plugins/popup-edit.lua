-- Popup edit helper: @ key for file path completion
return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "@",
        function()
          local row, col = table.unpack(vim.api.nvim_win_get_cursor(0))
          require("snacks").picker.files({
            hidden = true,
            ignored = true,
            confirm = function(picker, item)
              picker:close()
              if item then
                local path = item.file or item[1]
                if path then
                  vim.schedule(function()
                    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
                    local before = line:sub(1, col)
                    local after = line:sub(col + 1)
                    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { before .. path .. after })
                    vim.api.nvim_win_set_cursor(0, { row, col + #path })
                    vim.cmd("startinsert")
                  end)
                end
              end
            end,
          })
        end,
        desc = "Insert file path",
        mode = "i",
        ft = "markdown",
      },
    },
  },
}
