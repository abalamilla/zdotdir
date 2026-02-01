return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  init = function()
    -- Suppress obsidian.nvim footer errors after sleep/idle
    -- These occur when the note object becomes nil after Mac wakes from sleep
    vim.api.nvim_create_autocmd("VimResume", {
      pattern = "*",
      callback = function()
        -- Clear any pending obsidian async operations
        vim.schedule(function()
          pcall(function()
            local obsidian = require("obsidian")
            if obsidian and obsidian.get_client then
              local client = obsidian.get_client()
              if client then
                -- Force refresh the current buffer's note state
                vim.cmd("edit")
              end
            end
          end)
        end)
      end,
    })

    -- Autocmd to add title heading to new notes
    vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
      pattern = { "*/vimwiki/*.md", "*/vimwiki/*/*.md", "*/vimwiki/*/*/*.md" },
      callback = function()
        -- Small delay to let Obsidian add frontmatter first
        vim.defer_fn(function()
          local buf = vim.api.nvim_get_current_buf()
          if not vim.api.nvim_buf_is_valid(buf) then
            return
          end

          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

          -- Check if file is empty or only has frontmatter
          local content_start = 0
          local in_frontmatter = false

          for i, line in ipairs(lines) do
            if i == 1 and line == "---" then
              in_frontmatter = true
            elseif in_frontmatter and line == "---" then
              content_start = i
              break
            end
          end

          -- Check if there's actual content after frontmatter
          local has_content = false
          for i = content_start + 1, #lines do
            if lines[i]:match("%S") then -- Non-whitespace content
              has_content = true
              break
            end
          end

          -- If no content, add a title heading based on filename
          if not has_content then
            local filename = vim.fn.expand("%:t:r") -- Get filename without extension
            local title = filename:gsub("-", " ") -- Replace hyphens with spaces

            -- Insert heading after frontmatter or at start
            vim.api.nvim_buf_set_lines(buf, content_start, content_start, false, { "# " .. title, "" })
          end
        end, 100) -- 100ms delay
      end,
    })

    -- Autocmd to fold frontmatter by default
    vim.api.nvim_create_autocmd("BufReadPost", {
      pattern = { "*/vimwiki/*.md", "*/vimwiki/*/*.md", "*/vimwiki/*/*/*.md" },
      callback = function()
        vim.defer_fn(function()
          local buf = vim.api.nvim_get_current_buf()
          if not vim.api.nvim_buf_is_valid(buf) then
            return
          end

          -- Enable manual folding for this window
          vim.wo.foldmethod = "manual"

          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

          -- Check if file has frontmatter
          if #lines > 0 and lines[1] == "---" then
            -- Find end of frontmatter
            for i = 2, math.min(#lines, 50) do -- Check first 50 lines max
              if lines[i] == "---" then
                -- Create a fold for the frontmatter (lines 1 to i)
                vim.cmd(string.format("1,%dfold", i))
                break
              end
            end
          end
        end, 150) -- Delay to ensure file is fully loaded
      end,
    })
  end,
  keys = {
    -- Navigation
    {
      "<leader>Oi",
      function()
        local Obsidian = require("obsidian")
        local index_path = Obsidian.dir / "index.md"
        vim.cmd("edit " .. tostring(index_path))
      end,
      desc = "Open workspace index",
    },
    { "<leader>Of", "<cmd>Obsidian quick_switch<cr>", desc = "Find notes" },
    { "<leader>Os", "<cmd>Obsidian search<cr>", desc = "Search notes" },
    { "<leader>Ob", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
    { "<leader>Ol", "<cmd>Obsidian links<cr>", desc = "Links in note" },
    { "<leader>Ot", "<cmd>Obsidian tags<cr>", desc = "Find by tags" },
    { "<leader>Oo", "<cmd>Obsidian toc<cr>", desc = "Table of contents" },

    -- Daily notes
    { "<leader>Od", "<cmd>Obsidian today<cr>", desc = "Today's note" },
    { "<leader>Oy", "<cmd>Obsidian yesterday<cr>", desc = "Yesterday's note" },
    { "<leader>Om", "<cmd>Obsidian tomorrow<cr>", desc = "Tomorrow's note" },
    { "<leader>Oc", "<cmd>Obsidian dailies<cr>", desc = "Calendar (dailies)" },

    -- Note management
    { "<leader>On", "<cmd>Obsidian new<cr>", desc = "New note" },
    { "<leader>Or", "<cmd>Obsidian rename<cr>", desc = "Rename note" },
    { "<leader>Oe", "<cmd>Obsidian template<cr>", desc = "Insert template" },
    { "<leader>Op", "<cmd>Obsidian paste_img<cr>", desc = "Paste image" },

    -- Workspace
    { "<leader>Ow", "<cmd>Obsidian workspace<cr>", desc = "Switch workspace" },

    -- Visual mode mappings
    {
      "<CR>",
      function()
        -- Save the current register
        local saved_reg = vim.fn.getreg('"')
        local saved_regtype = vim.fn.getregtype('"')

        -- Yank the visual selection
        vim.cmd('normal! "vy')
        local text = vim.fn.getreg("v")

        -- Normalize the text to create the filename (same logic as note_id_func)
        local normalized = text
        normalized = normalized:gsub(":", "-") -- Replace : with -
        normalized = normalized:gsub("%.", "-") -- Replace . with -
        normalized = normalized:gsub(" ", "-") -- Replace spaces with -
        normalized = normalized:gsub("@", "-") -- Replace @ with -
        normalized = normalized:gsub("[^A-Za-z0-9%-_]", "") -- Remove special chars
        normalized = normalized:gsub("%-+", "-") -- Collapse multiple hyphens
        normalized = normalized:gsub("^%-+", ""):gsub("%-+$", "") -- Trim hyphens

        -- Create wiki link with normalized filename and display text
        local link = "[[" .. normalized .. "|" .. text .. "]]"

        -- Replace the selection with the link
        vim.fn.setreg("v", link)
        vim.cmd('normal! gv"vp')

        -- Restore the register
        vim.fn.setreg('"', saved_reg, saved_regtype)
      end,
      desc = "Create wiki link from selection",
      mode = "v",
      ft = "markdown",
    },
    { "<leader>Ol", ":'<,'>Obsidian link<cr>", desc = "Link to existing note", mode = "v" },
    { "<leader>On", ":'<,'>Obsidian link_new<cr>", desc = "New note from selection", mode = "v" },
    { "<leader>Ox", ":'<,'>Obsidian extract_note<cr>", desc = "Extract to note", mode = "v" },

    -- Quick actions
    { "<leader>Ox", "<cmd>Obsidian toggle_checkbox<cr>", desc = "Toggle checkbox" },
    { "gf", "<cmd>Obsidian follow_link<cr>", desc = "Follow link" },
  },
  opts = {
    legacy_commands = false,
    workspaces = {
      {
        name = "pgd",
        path = "~/vimwiki/pgd",
      },
      {
        name = "ab",
        path = "~/vimwiki/ab",
      },
    },

    -- Daily notes
    daily_notes = {
      folder = "diary",
      date_format = "%Y-%m-%d",
    },

    -- Note ID function - use filename instead of random ID
    -- Normalizes names to match wiki conventions: spaces, colons, dots, @ replaced with hyphens
    note_id_func = function(title)
      -- Use the title as the ID (filename without extension)
      -- If title is nil, generate a simple timestamp-based name
      if title == nil then
        return tostring(os.date("%Y-%m-%d-%H%M%S"))
      end

      -- Normalize the title to match our filename convention
      local normalized = title
      -- Replace special characters with hyphens
      normalized = normalized:gsub(":", "-") -- Replace : with -
      normalized = normalized:gsub("%.", "-") -- Replace . with -
      normalized = normalized:gsub(" ", "-") -- Replace spaces with -
      normalized = normalized:gsub("@", "-") -- Replace @ with -
      -- Remove any other special characters that shouldn't be in filenames
      normalized = normalized:gsub("[^A-Za-z0-9%-_]", "")
      -- Replace multiple hyphens with single hyphen
      normalized = normalized:gsub("%-+", "-")
      -- Trim leading/trailing hyphens
      normalized = normalized:gsub("^%-+", ""):gsub("%-+$", "")

      return normalized
    end,

    -- Note path function - create notes in same directory as current file
    note_path_func = function(spec)
      local Path = require("obsidian").Path
      local buf_path = vim.api.nvim_buf_get_name(0)

      -- If we have a valid buffer path, use its directory
      if buf_path and buf_path ~= "" then
        local current_dir = vim.fn.fnamemodify(buf_path, ":h")
        return Path.new(current_dir) / tostring(spec.id)
      end

      -- Fallback to default behavior
      return spec.dir / tostring(spec.id)
    end,

    -- Note frontmatter - preserve or generate tags
    frontmatter = {
      func = function(note)
        local tags = note.tags or {}

        -- If no tags exist, generate them from the file path
        if #tags == 0 then
          local note_path = tostring(note.path)

          -- Try to find workspace root in the path
          for _, ws in ipairs({ "ab", "pgd", "vimwiki", "jira-reports", "assets" }) do
            local pattern = "/" .. ws .. "/"
            local idx = note_path:find(pattern)

            if idx then
              -- Found workspace, add it as first tag
              table.insert(tags, ws)

              -- Get relative path after workspace
              local rel_path = note_path:sub(idx + #pattern)
              -- Remove filename to get directory path
              local dir_path = vim.fn.fnamemodify(rel_path, ":h")

              -- Add directory components as tags
              if dir_path ~= "." and dir_path ~= "" then
                for dir in string.gmatch(dir_path, "[^/]+") do
                  table.insert(tags, dir)
                end
              end

              break
            end
          end
        end

        local out = { id = note.id, aliases = note.aliases or {}, tags = tags }

        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end

        return out
      end,
    },

    -- Picker configuration - avoid conflict with LazyVim's Ctrl+l
    picker = {
      name = "telescope.nvim",
      note_mappings = {
        new = "<C-x>",
        insert_link = "<C-y>", -- Changed from <C-l> to avoid conflict with window navigation
      },
      tag_mappings = {
        tag_note = "<C-x>",
        insert_tag = "<C-y>",
      },
    },

    -- Disable completion (LazyVim uses blink.cmp by default)
    completion = {
      nvim_cmp = false,
    },

    -- Disable obsidian UI (use render-markdown instead)
    ui = {
      enable = false,
      -- Explicitly disable footer to prevent errors after sleep/idle
      update_debounce = 0,
      max_file_length = 0,
    },
  },
}
