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

-- neo-tree
vim.api.nvim_create_autocmd("BufEnter", {
  -- make a group to be able to delete it later
  group = vim.api.nvim_create_augroup("NeoTreeInit", { clear = true }),
  callback = function()
    local f = vim.fn.expand("%:p")
    if vim.fn.isdirectory(f) ~= 0 then
      vim.cmd("Neotree current dir=" .. f)
      -- neo-tree is loaded now, delete the init autocmd
      vim.api.nvim_clear_autocmds({ group = "NeoTreeInit" })
    end
  end,
})
