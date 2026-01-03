-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Icon picker in insert mode
vim.keymap.set("i", "<C-i>", function()
  Snacks.picker.icons()
end, { desc = "Pick icon" })
