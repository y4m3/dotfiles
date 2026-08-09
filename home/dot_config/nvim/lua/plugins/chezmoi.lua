return {
  -- Correct two-layer highlighting (target language + Go template) for
  -- chezmoi source files. Only the highlight plugin: the LazyVim
  -- util.chezmoi extra also ships apply-on-save, which we do not want.
  {
    "alker0/chezmoi.vim",
    lazy = false,
    init = function()
      -- Detect the inner language of *.tmpl via a scratch buffer named
      -- after the stripped path; without it every template degrades to
      -- the generic template.chezmoitmpl filetype.
      vim.g["chezmoi#use_tmp_buffer"] = true
    end,
  },
}
