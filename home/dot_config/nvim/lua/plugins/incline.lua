-- Diagnostic icons (resolved once at load time)
local function get_diagnostic_icons()
  local ok, lazyvim_config = pcall(require, "lazyvim.config")
  local icons = ok and lazyvim_config.icons.diagnostics
    or { Error = " ", Warn = " ", Info = " ", Hint = " " }
  return {
    { severity = vim.diagnostic.severity.ERROR, icon = icons.Error, group = "DiagnosticError" },
    { severity = vim.diagnostic.severity.WARN, icon = icons.Warn, group = "DiagnosticWarn" },
    { severity = vim.diagnostic.severity.INFO, icon = icons.Info, group = "DiagnosticInfo" },
    { severity = vim.diagnostic.severity.HINT, icon = icons.Hint, group = "DiagnosticHint" },
  }
end

return {
  {
    "b0o/incline.nvim",
    event = "VeryLazy",
    config = function(_, opts)
      local diag_icons = get_diagnostic_icons()
      opts.render = function(props)
        local result = {}
        local counts = vim.diagnostic.count(props.buf)
        for _, item in ipairs(diag_icons) do
          local n = counts[item.severity] or 0
          if n > 0 then
            table.insert(result, { item.icon .. n .. " ", group = item.group })
          end
        end
        return result
      end
      require("incline").setup(opts)
    end,
  },
}
