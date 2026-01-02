return {
  "dhruvasagar/vim-table-mode",
  ft = { "markdown", "text" },
  init = function()
    -- Use markdown-compatible tables
    vim.g.table_mode_corner = "|"
    vim.g.table_mode_corner_corner = "|"
    vim.g.table_mode_header_fillchar = "-"
  end,
}
