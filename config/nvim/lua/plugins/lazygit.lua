if not vim.g.vscode then
  return {
    {
      "kdheepak/lazygit.nvim",
      dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim",
      },
      opts = {
        setup_autocmd = true, -- Custom flag for autocmd setup
      },
      config = function(_, opts)
        require("telescope").load_extension("lazygit")
        if opts.setup_autocmd then
          vim.api.nvim_create_autocmd({ "BufEnter" }, {
            callback = function()
              require("lazygit.utils").project_root_dir()
            end,
          })
        end
      end,
      cmd = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
      },
      keys = {
        { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
      },
    },
  }
else
  return {}
end
