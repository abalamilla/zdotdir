return {
  "Vigemus/iron.nvim",
  lazy = true,
  keys = {
    { "<leader>ir", desc = "Iron: Toggle REPL" },
    { "<leader>is", mode = "n", desc = "Iron: Send line" },
    { "<leader>is", mode = "v", desc = "Iron: Send selection" },
  },
  config = function()
    local iron = require("iron.core")
    local view = require("iron.view")

    iron.setup({
      config = {
        scratch_repl = true,
        repl_definition = {
          python = { command = { "python3" } },
          lua = { command = { "lua" } },
          sh = { command = { "zsh" } },
          pkl = { command = { "pkl", "repl" } },
        },
        repl_open_cmd = view.split.vertical.botright(0.3),
      },
      keymaps = {
        toggle_repl = "<leader>ir",
      },
    })

    -- Detect code block language in markdown files by searching backwards for opening ```
    -- Returns language string (e.g., "pkl", "python") or nil if not in a code block
    local function get_markdown_lang(line_num)
      local bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

      for i = line_num - 1, 0, -1 do
        local line = lines[i]
        if line:match("^```") then
          return line:match("^```([a-z0-9]+)")
        end
      end
      return nil
    end

    -- Determine the target REPL language for the current context
    -- For markdown files, detects language from code fence; otherwise uses filetype
    local function get_target_lang(line_num, filetype)
      if filetype == "markdown" then
        return get_markdown_lang(line_num)
      end
      return filetype
    end

    -- Send content to REPL with language detection and error handling
    local function send_to_repl(content, line_num, filetype)
      local lang = get_target_lang(line_num, filetype)

      if not lang then
        vim.notify("Not in a code block", vim.log.levels.WARN)
        return false
      end

      iron.send(lang, content)
      return true
    end

    -- Send current line to REPL
    local function send_line()
      local bufnr = vim.api.nvim_get_current_buf()
      local filetype = vim.bo[bufnr].filetype
      local line_num = vim.fn.line(".")
      local line = vim.fn.getline(line_num)

      send_to_repl(line, line_num, filetype)
    end

    -- Send visual selection to REPL
    -- Must be called from visual mode; exits visual mode to preserve marks
    local function send_selection()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)

      -- Schedule after visual mode exits to access < and > marks
      vim.schedule(function()
        local filetype = vim.bo.filetype
        local start_mark = vim.api.nvim_buf_get_mark(0, "<")
        local end_mark = vim.api.nvim_buf_get_mark(0, ">")
        local start_line = start_mark[1]
        local end_line = end_mark[1]

        if start_line == 0 or end_line == 0 then
          vim.notify("No visual selection found", vim.log.levels.WARN)
          return
        end

        local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
        send_to_repl(lines, start_line, filetype)
      end)
    end

    -- Set keymaps
    vim.keymap.set("n", "<leader>is", send_line, { desc = "Iron: Send line" })
    vim.keymap.set("v", "<leader>is", send_selection, { desc = "Iron: Send selection" })
  end,
}

