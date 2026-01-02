local M = {}

-- Convert indented text to markdown bullets
-- Usage: Visual select text, then call this function
-- Every 2 spaces of indentation = 1 bullet level
function M.indent_to_bullets(start_line, end_line)
  -- If called without arguments, try to get visual selection
  if not start_line then
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    start_line = start_pos[2]
    end_line = end_pos[2]
  end

  -- Validate line numbers
  if not start_line or not end_line or start_line == 0 or end_line == 0 then
    vim.notify("No valid visual selection", vim.log.levels.WARN)
    return
  end

  -- Ensure start is before end
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  local new_lines = {}
  for _, line in ipairs(lines) do
    if line:match("^%s*$") then
      -- Keep empty lines
      table.insert(new_lines, line)
    else
      -- Count leading spaces and convert to bullet
      local indent = line:match("^(%s*)") or ""
      local content = line:match("^%s*(.+)") or ""
      if content ~= "" then
        local level = math.floor(#indent / 2)
        local bullet_indent = string.rep("  ", level)
        table.insert(new_lines, bullet_indent .. "- " .. content)
      else
        table.insert(new_lines, line)
      end
    end
  end

  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, new_lines)
end

-- Adjust heading level for current heading and all its children
-- When cursor is on a heading, this will increase/decrease the level
-- of that heading and all child headings (stops at sibling/parent headings)
function M.adjust_heading_tree(increase)
  local start_line = vim.fn.line(".")
  local current = vim.fn.getline(start_line)
  local current_level = current:match("^(#+)%s")

  if not current_level then
    return
  end

  local target_level = #current_level
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, -1, false)

  for i = 2, #lines do
    local line = lines[i]
    local level = line:match("^(#+)%s")

    if level then
      local heading_level = #level
      -- Stop if we hit a heading at same or higher level (sibling or parent)
      if heading_level <= target_level then
        break
      end

      -- Adjust child heading
      local line_num = start_line + i - 1
      if increase then
        vim.fn.setline(line_num, "#" .. line)
      else
        if heading_level > 1 then
          vim.fn.setline(line_num, line:sub(2))
        end
      end
    end
  end

  -- Adjust current line last
  if increase then
    vim.fn.setline(start_line, "#" .. current)
  else
    if target_level > 1 then
      vim.fn.setline(start_line, current:sub(2))
    end
  end
end

return M
