-- Denops.vim: A plugin ecosystem that uses Deno runtime.
-- Deno runtime is managed via Nix Home Manager (see home.nix).
return {
  {
    "vim-denops/denops.vim",
    lazy = false,
    init = function()
      local deno = vim.fn.exepath("deno")
      if deno ~= "" then
        vim.g["denops#deno"] = deno
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "DenopsReady",
        callback = function()
          vim.fn["denops#plugin#discover"]()
        end,
      })
    end,
  },
}
