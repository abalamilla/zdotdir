-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Icon picker in insert mode
vim.keymap.set("i", "<C-i>", function()
  Snacks.picker.icons()
end, { desc = "Pick icon" })

-- Markdown formatting in visual mode
local function wrap_selection(prefix, suffix)
  return function()
    -- Get visual selection range
    local start_row, start_col = unpack(vim.api.nvim_buf_get_mark(0, "<"))
    local end_row, end_col = unpack(vim.api.nvim_buf_get_mark(0, ">"))

    -- Get the selected text
    local lines = vim.api.nvim_buf_get_text(0, start_row - 1, start_col, end_row - 1, end_col + 1, {})

    -- Wrap first and last line
    if #lines == 1 then
      lines[1] = prefix .. lines[1] .. suffix
    else
      lines[1] = prefix .. lines[1]
      lines[#lines] = lines[#lines] .. suffix
    end

    -- Replace the text
    vim.api.nvim_buf_set_text(0, start_row - 1, start_col, end_row - 1, end_col + 1, lines)

    -- Exit visual mode
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  end
end

vim.keymap.set("v", "gB", wrap_selection("**", "**"), { desc = "Bold" })
vim.keymap.set("v", "gI", wrap_selection("*", "*"), { desc = "Italic" })
vim.keymap.set("v", "gS", wrap_selection("~~", "~~"), { desc = "Strikethrough" })

-- Insert mode markdown formatting
vim.keymap.set("i", "<C-g>b", function()
  vim.api.nvim_put({ "****" }, "c", false, true)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Left><Left>", true, false, true), "n", false)
end, { desc = "Insert bold markers" })

vim.keymap.set("i", "<C-g>i", function()
  vim.api.nvim_put({ "**" }, "c", false, true)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Left>", true, false, true), "n", false)
end, { desc = "Insert italic markers" })

vim.keymap.set("i", "<C-g>s", function()
  vim.api.nvim_put({ "~~~~" }, "c", false, true)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Left><Left>", true, false, true), "n", false)
end, { desc = "Insert strikethrough markers" })
