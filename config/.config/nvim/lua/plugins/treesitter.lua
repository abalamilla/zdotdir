return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    auto_install = true,
    ensure_installed = {
      "markdown",
      "markdown_inline",
    },
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
    sync_install = false,
  },
  init = function()
    -- Map vimwiki filetype to use markdown parser
    vim.treesitter.language.register("markdown", "vimwiki")
  end,
}
