return {
  "jay-babu/mason-nvim-dap.nvim",
  dependencies = {
    "mason-org/mason.nvim",
    "mfussenegger/nvim-dap",
  },
  opts = {
    ensure_installed = { "codelldb" },
    automatic_installation = true,
  },
}
