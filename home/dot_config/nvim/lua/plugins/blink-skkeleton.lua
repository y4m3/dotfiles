return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "saghen/blink.compat",
      "uga-rosa/cmp-skkeleton",
    },
    opts = function(_, opts)
      -- Add skkeleton to sources
      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or {}
      table.insert(opts.sources.default, "skkeleton")

      -- Configure skkeleton provider
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.skkeleton = {
        name = "skkeleton",
        module = "blink.compat.source",
      }

      -- Disable completion when skkeleton (Japanese IME) is active
      local prev_enabled = opts.enabled
      opts.enabled = function(...)
        if vim.g.skkeleton_enabled then
          return false
        end
        if vim.bo.buftype == "prompt" then
          return false
        end
        if type(prev_enabled) == "function" then
          return prev_enabled(...)
        elseif prev_enabled ~= nil then
          return prev_enabled
        end
        return true
      end

      return opts
    end,
  },
}
