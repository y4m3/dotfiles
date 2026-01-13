return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- Exclude markdown-toc, keep prettier only
        markdown = { "prettier" },
        ["markdown.mdx"] = { "prettier" },
      },
    },
  },
}
