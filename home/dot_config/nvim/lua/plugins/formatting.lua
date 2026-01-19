return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      local function get_python_root(bufnr)
        local fname = vim.api.nvim_buf_get_name(bufnr or 0)
        return vim.fs.root(fname, { "pyproject.toml", "requirements.txt", "setup.cfg", "setup.py", ".git" })
      end

      local function venv_ruff(root)
        if not root then
          return nil
        end
        local is_win = vim.fn.has("win32") == 1
        local path = is_win and (root .. "\\.venv\\Scripts\\ruff.exe") or (root .. "/.venv/bin/ruff")
        return (vim.fn.filereadable(path) == 1) and path or nil
      end

      opts.formatters = opts.formatters or {}
      opts.formatters.ruff_format = {
        command = function(_, ctx)
          local root = get_python_root(ctx.buf)
          return venv_ruff(root) or "ruff"
        end,
      }

      opts.formatters_by_ft = opts.formatters_by_ft or {}
      -- Exclude markdown-toc, keep prettier only
      opts.formatters_by_ft.markdown = { "prettier" }
      opts.formatters_by_ft["markdown.mdx"] = { "prettier" }

      return opts
    end,
  },
}
