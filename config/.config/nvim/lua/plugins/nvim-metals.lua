return {
  "scalameta/nvim-metals",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "mfussenegger/nvim-dap",
  },
  ft = { "scala", "sbt" },
  config = function()
    local metals = require("metals")

    local metals_config = metals.bare_config()
    metals_config.settings = {
      showImplicitArguments = true,
      superMethodLensesEnabled = true,
    }
    metals_config.on_attach = function(client, bufnr)
      metals.setup_dap()
    end

    local group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = { "scala", "sbt" },
      callback = function()
        metals.initialize_or_attach(metals_config)
      end,
    })
  end,
}