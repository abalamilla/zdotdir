return {
  {
    "apple/pkl-neovim",
    ft = "pkl",
    config = function()
      vim.g.pkl_neovim = {
        start_command = { "pkl-lsp" },
      }

      -- Add command to evaluate current Pkl file
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "pkl",
        callback = function(ev)
          vim.keymap.set("n", "<leader>pr", function()
            local file = vim.fn.expand("%:p")
            vim.cmd("terminal pkl eval " .. file)
          end, { desc = "Pkl: Run/Eval file", buffer = ev.buf })
        end,
      })
    end,
  },

  -- Ensure treesitter has pkl parser
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "pkl" })
    end,
  },

  -- Install pkl-lsp via Mason
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "pkl-lsp" })
    end,
  },
}
