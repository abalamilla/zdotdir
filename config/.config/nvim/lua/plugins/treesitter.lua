return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    auto_install = true,
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
    sync_install = false,
    parser_install_dir = vim.fn.stdpath("data") .. "/treesitter",
  },
}
