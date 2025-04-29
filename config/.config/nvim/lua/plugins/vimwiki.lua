return {
  "vimwiki/vimwiki",
  init = function()
    vim.g.vimwiki_auto_header = 1
    vim.g.vimwiki_listing_hl = 1
    vim.g.vimwiki_global_ext = 0

    vim.g.vimwiki_list = {
      {
        path = "~/vimwiki/pgd/",
        diary_frequency = "weekly",
        syntax = "markdown",
        ext = "md",
      },
      {
        path = "~/vimwiki/ab/",
        diary_frequency = "weekly",
        syntax = "markdown",
        ext = "md",
      },
    }
  end,
}
