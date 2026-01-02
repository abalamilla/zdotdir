-- Markdown utility functions are defined in lua/utils/markdown.lua
-- Add new markdown-related functions there to keep this file clean

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
    -- Enable treesitter folding globally for all file types
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.opt.foldenable = true
    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 99

    -- Set up markdown keymaps
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown" },
      callback = function(ev)
        -- Set up markdown utility keymaps
        local md = require("utils.markdown")

        vim.keymap.set("n", "<leader>h+", function()
          md.adjust_heading_tree(true)
        end, { desc = "Increase heading tree level", buffer = ev.buf })

        vim.keymap.set("n", "<leader>h-", function()
          md.adjust_heading_tree(false)
        end, { desc = "Decrease heading tree level", buffer = ev.buf })

        -- Create a command that accepts a range
        vim.api.nvim_buf_create_user_command(ev.buf, "IndentToBullets", function(opts)
          md.indent_to_bullets(opts.line1, opts.line2)
        end, { range = true })

        vim.keymap.set(
          "x",
          "<leader>hb",
          ":IndentToBullets<CR>",
          { desc = "Convert indent to bullets", buffer = ev.buf }
        )
      end,
    })
  end,
}
