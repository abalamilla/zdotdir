return {
  "jpalardy/vim-slime",
  init = function()
    -- Use Neovim's built-in terminal as target
    vim.g.slime_target = "neovim"
    vim.g.slime_no_mappings = true

    -- Auto-detect first terminal buffer
    vim.g.slime_get_jobid = function()
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_get_option_value("buftype", { buf = bufnr }) == "terminal" then
          local chan = vim.api.nvim_get_option_value("channel", { buf = bufnr })
          if chan and chan > 0 then
            return chan
          end
        end
      end
      return nil
    end
  end,
  config = function()
    -- Enable bracketed paste for proper text handling
    vim.g.slime_bracketed_paste = 1
    vim.g.slime_suggest_default = false
  end,
  keys = {
    { "<C-c><C-c>", "<Plug>SlimeRegionSend", mode = "v", desc = "Slime: Send region to terminal" },
    { "<leader>ss", "<Plug>SlimeLineSend", desc = "Slime: Send line to terminal" },
    { "<leader>ss", "<Plug>SlimeRegionSend", mode = "v", desc = "Slime: Send region to terminal" },
    { "<leader>st", "<Cmd>terminal<CR>", desc = "Open terminal" },
    { "<leader>sc", "<Cmd>SlimeConfig<CR>", desc = "Slime: Configure target" },
  },
}

