-- Denops.vim: A plugin ecosystem that uses Deno runtime.
-- Deno runtime is managed via Nix Home Manager (see home.nix).
return {
  {
    "vim-denops/denops.vim",
    lazy = true, -- Load only when required by dependent plugins (skkeleton, kensaku, etc.)
  },
}
