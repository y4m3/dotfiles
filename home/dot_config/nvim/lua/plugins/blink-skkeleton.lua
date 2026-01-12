return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "saghen/blink.compat",
      "uga-rosa/cmp-skkeleton",
    },
    opts = {
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "skkeleton" },
        providers = {
          skkeleton = {
            name = "skkeleton",
            module = "blink.compat.source",
          },
        },
      },
    },
  },
}
