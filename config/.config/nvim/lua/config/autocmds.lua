-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Telescope: add numbers to telescope results window
vim.api.nvim_create_autocmd("User", {
  pattern = "TelescopePreviewerLoaded",
  callback = function()
    vim.wo.number = true
    vim.wo.cursorline = true
    vim.wo.wrap = true
  end,
})

-- clear existing autocmd from lazyvim
vim.api.nvim_clear_autocmds({ group = "lazyvim_wrap_spell" })

-- create custom autocmd
-- wrap and check for spell in text filetypes
local spell_filetypes = { "text", "plaintex", "typst", "gitcommit", "markdown", "vimwiki" }
vim.api.nvim_create_autocmd("FileType", {
  pattern = spell_filetypes,
  callback = function()
    vim.opt_local.spell = true
  end,
})
