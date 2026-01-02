return {
  "dkarter/bullets.vim",
  ft = { "markdown", "text" },
  init = function()
    vim.g.bullets_enabled_file_types = { "markdown", "text" }
  end,
}
