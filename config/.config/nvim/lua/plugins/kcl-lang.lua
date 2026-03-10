return {
  {
    "kcl-lang/kcl.nvim",
    ft = "kcl",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      -- Setup KCL LSP
      require("lspconfig").kcl.setup({})
    end,
  },

  -- Install kcl-language-server via Mason
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "kcl" })
    end,
  },
}