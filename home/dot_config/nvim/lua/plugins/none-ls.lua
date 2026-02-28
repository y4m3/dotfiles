return {
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      local filtered = {}
      for _, source in ipairs(opts.sources or {}) do
        if source ~= nls.builtins.formatting.fish_indent and source ~= nls.builtins.diagnostics.fish then
          table.insert(filtered, source)
        end
      end
      opts.sources = filtered
      return opts
    end,
  },
}
