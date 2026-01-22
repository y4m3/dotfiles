-- LSP configuration: .venv priority > PATH fallback
-- Python tools prefer project's .venv, fallback to PATH (Nix/uv tool)

local function venv_path(root, exe)
  if not root then
    return nil
  end
  local is_win = vim.fn.has("win32") == 1
  local path = is_win and (root .. "\\.venv\\Scripts\\" .. exe .. ".exe") or (root .. "/.venv/bin/" .. exe)
  return (vim.fn.filereadable(path) == 1) and path or nil
end

local function get_venv_python(root)
  if not root then
    return nil
  end
  local is_win = vim.fn.has("win32") == 1
  local path = is_win and (root .. "\\.venv\\Scripts\\python.exe") or (root .. "/.venv/bin/python")
  return (vim.fn.filereadable(path) == 1) and path or nil
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      opts.servers.nil_ls = {
        mason = false, -- Managed by Nix Home Manager
      }

      opts.servers.ruff = {
        mason = false,
        before_init = function(_, config)
          local root = config.root_dir or ""
          local ruff = venv_path(root, "ruff") or "ruff"
          config.cmd = { ruff, "server" }
        end,
      }

      opts.servers.pyright = {
        mason = false,
        before_init = function(_, config)
          local root = config.root_dir or ""
          local pyright = venv_path(root, "pyright-langserver") or "pyright-langserver"
          config.cmd = { pyright, "--stdio" }

          local python = get_venv_python(root)
          if python then
            config.settings = config.settings or {}
            config.settings.python = config.settings.python or {}
            config.settings.python.pythonPath = python
          end
        end,
      }

      return opts
    end,
  },
}
