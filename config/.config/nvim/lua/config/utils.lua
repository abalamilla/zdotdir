-- Utility function to get the hostname
local isWorkBox = vim.fn.hostname():match("^WK")

-- Language configurations for markdown code blocks
local LANG_CONFIG = {
  kcl = { ext = "kcl", cmd = "kclvm_cli run" },
  python = { ext = "py", cmd = "python" },
  go = { ext = "go", cmd = "go run" },
  kotlin = { ext = "kt", cmd = "kotlinc-jvm -script" },
  java = { ext = "java", cmd = "java" },
  bash = { ext = "sh", cmd = "bash" },
  sh = { ext = "sh", cmd = "bash" },
  javascript = { ext = "js", cmd = "node" },
  js = { ext = "js", cmd = "node" },
}

-- Extract code block at cursor or visual selection
local function extract_code_block()
  local start_line, end_line

  if vim.fn.mode() == "v" or vim.fn.mode() == "V" then
    -- Visual mode
    start_line = vim.fn.line("'<")
    end_line = vim.fn.line("'>")
  else
    -- Normal mode: find surrounding code block
    local current_line = vim.fn.line(".")
    start_line = current_line
    end_line = current_line

    -- Search backward for opening ```
    while start_line > 1 do
      local line = vim.fn.getline(start_line)
      if line:match("^```") then
        break
      end
      start_line = start_line - 1
    end

    -- Search forward for closing ```
    while end_line <= vim.fn.line("$") do
      local line = vim.fn.getline(end_line)
      if line:match("^```") and end_line ~= start_line then
        break
      end
      end_line = end_line + 1
    end
  end

  -- Get language from opening fence
  local fence_line = vim.fn.getline(start_line)
  local lang = fence_line:match("^```(%w+)") or ""

  -- Extract code (exclude fence lines)
  local code_lines = vim.fn.getline(start_line + 1, end_line - 1)
  local code = table.concat(code_lines, "\n")

  return code, lang
end

-- Run markdown code block with overseer
local function run_markdown_code()
  local code, lang = extract_code_block()

  if not code or code == "" then
    vim.notify("No code block found", vim.log.levels.WARN)
    return
  end

  local config = LANG_CONFIG[lang]
  if not config then
    vim.notify("Language '" .. lang .. "' not configured", vim.log.levels.WARN)
    return
  end

  -- Create temp file
  local temp_dir = "/tmp"
  local timestamp = vim.fn.strftime("%s")
  local temp_file = temp_dir .. "/nvim_" .. timestamp .. "." .. config.ext

  -- Write code to temp file
  local f = io.open(temp_file, "w")
  if not f then
    vim.notify("Failed to create temp file", vim.log.levels.ERROR)
    return
  end
  f:write(code)
  f:close()

  -- Build command
  local cmd = config.cmd .. " " .. temp_file

  -- Get overseer if available
  local overseer_ok, overseer = pcall(require, "overseer")
  if not overseer_ok then
    vim.notify("Overseer not available", vim.log.levels.WARN)
    return
  end

  -- Run task with overseer
  local task = overseer.new_task({
    cmd = "bash",
    args = { "-c", cmd },
  })

  if task then
    task:start()
    vim.notify("Running: " .. cmd .. "\nUse :OverseerToggle to see output", vim.log.levels.INFO)
  else
    vim.notify("Failed to create task", vim.log.levels.ERROR)
  end
end

return {
  isWorkBox = isWorkBox,
  extract_code_block = extract_code_block,
  run_markdown_code = run_markdown_code,
  LANG_CONFIG = LANG_CONFIG,
}
