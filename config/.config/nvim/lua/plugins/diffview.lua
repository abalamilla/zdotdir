local close_panel = { "n", "<esc>", "", { desc = "Close file panel" } }

-- Function to select and diff multiple commits
local function multi_commit_diff()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  -- Get grep pattern from user
  local grep_pattern = vim.fn.input("Filter commits (grep pattern, or leave empty): ")

  -- Build git log command
  local git_cmd = { "git", "log", "--oneline", "--no-merges", "-n", "100" }
  if grep_pattern ~= "" then
    table.insert(git_cmd, "--grep=" .. grep_pattern)
  end

  -- Get commits
  local commits = vim.fn.systemlist(git_cmd)

  if #commits == 0 then
    vim.notify("No commits found", vim.log.levels.WARN)
    return
  end

  pickers
    .new({}, {
      prompt_title = "Select Commits (Tab to select multiple, Enter to diff)",
      finder = finders.new_table({
        results = commits,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local picker = action_state.get_current_picker(prompt_bufnr)
          local selections = picker:get_multi_selection()
          actions.close(prompt_bufnr)

          -- If no multi-selection, use current selection
          if #selections == 0 then
            local selection = action_state.get_selected_entry()
            selections = { selection }
          end

          if #selections == 0 then
            vim.notify("No commits selected", vim.log.levels.WARN)
            return
          end

          -- Extract commit hashes
          local commit_hashes = {}
          for _, selection in ipairs(selections) do
            local hash = selection.value:match("^(%S+)")
            table.insert(commit_hashes, hash)
          end

          -- Sort commits by git order (oldest to newest)
          local sorted_commits = vim.fn.systemlist(
            string.format("git rev-list --no-walk --topo-order --reverse %s", table.concat(commit_hashes, " "))
          )

          if #sorted_commits == 1 then
            -- Single commit: show commit diff
            vim.cmd("DiffviewOpen " .. sorted_commits[1] .. "^.." .. sorted_commits[1])
          else
            -- Get files changed ONLY in selected commits (not in-between commits)
            local files = {}
            local file_set = {}

            for _, commit in ipairs(sorted_commits) do
              local changed_files = vim.fn.systemlist(string.format("git diff-tree --no-commit-id --name-only -r %s", commit))
              for _, file in ipairs(changed_files) do
                if file ~= "" and not file_set[file] then
                  file_set[file] = true
                  table.insert(files, file)
                end
              end
            end

            local base = sorted_commits[1] .. "^"
            local head = sorted_commits[#sorted_commits]
            local diff_range = base .. ".." .. head

            -- Show options
            local choice = vim.fn.confirm(
              string.format("View %d commits, %d files (range: %s):", #sorted_commits, #files, diff_range),
              "&Diffview \n&Patch text view\n&Per-commit view\n&Cancel",
              1
            )

            if choice == 1 then
              -- Ask about whitespace
              local ws_choice = vim.fn.confirm("Whitespace handling:", "&Show all\n&Ignore whitespace", 1)

              local cmd = "DiffviewOpen "
              if ws_choice == 2 then
                cmd = cmd .. "-w " -- ignore all whitespace
              end
              cmd = cmd .. diff_range .. " -- " .. table.concat(files, " ")

              vim.cmd(cmd)
            elseif choice == 2 then
              -- Patch text: show each commit's full patch
              local patches = {}
              table.insert(patches, "# Patch view: " .. #sorted_commits .. " commits")
              table.insert(patches, "# Range: " .. diff_range)
              table.insert(patches, "")

              for _, commit in ipairs(sorted_commits) do
                local patch = vim.fn.systemlist(string.format("git show --format='%%n==== %%h: %%s ====%%n' %s", commit))
                vim.list_extend(patches, patch)
                table.insert(patches, "")
              end

              local buf = vim.api.nvim_create_buf(false, true)
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, patches)
              vim.api.nvim_buf_set_option(buf, "filetype", "diff")
              vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
              vim.api.nvim_buf_set_name(buf, "Patches: " .. #sorted_commits .. " commits")

              vim.cmd("vsplit")
              vim.api.nvim_win_set_buf(0, buf)
            elseif choice == 3 then
              -- Per-commit view: show first commit, notify about others
              vim.cmd("DiffviewOpen " .. sorted_commits[1] .. "^.." .. sorted_commits[1])
              if #sorted_commits > 1 then
                local others = {}
                for i = 2, #sorted_commits do
                  table.insert(others, sorted_commits[i])
                end
                vim.notify(
                  string.format("Showing 1/%d commits. Others: %s", #sorted_commits, table.concat(others, ", ")),
                  vim.log.levels.INFO
                )
              end
            end
          end
        end)
        return true
      end,
    })
    :find()
end

return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    { "<leader>gdvc", ":DiffviewClose<CR>", desc = "Close Diffview" },
    { "<leader>gdvo", ":DiffviewOpen<CR>", desc = "Open Diffview" },
    { "<leader>gdvl", ":DiffviewLog<CR>", desc = "Open Diffview Log" },
    { "<leader>gdvh", ":DiffviewFileHistory<CR>", desc = "Open Diffview File History" },
    {
      "<leader>gdvg",
      function()
        local grep_pattern = vim.fn.input("Grep pattern: ")
        if grep_pattern ~= "" then
          vim.cmd("DiffviewFileHistory --grep=" .. grep_pattern)
        end
      end,
      desc = "Diffview File History with grep",
    },
    {
      "<leader>gdvm",
      multi_commit_diff,
      desc = "Multi-commit diff (filter & select)",
    },
    {
      "<leader>gdvw",
      function()
        vim.cmd("DiffviewOpen -w")
      end,
      desc = "Diffview ignore whitespace",
    },
  },
  opts = {
    diff_binaries = false,
    enhanced_diff_hl = true,
    use_icons = true,
    signs = {
      fold_closed = "",
      fold_open = "",
      done = "✓",
    },
    -- Git command options to ignore whitespace
    git_cmd = { "git" },
    default_args = {
      DiffviewOpen = { "--imply-local" },
      DiffviewFileHistory = {},
    },
    view = {
      default = {
        layout = "diff2_horizontal",
        winbar_info = true,
      },
      merge_tool = {
        layout = "diff3_horizontal",
      },
      file_history = {
        layout = "diff2_horizontal",
        winbar_info = true,
      },
    },
    file_panel = {
      listing_style = "tree",
      tree_options = {
        flatten_dirs = true,
        folder_statuses = "only_folded",
      },
      win_config = {
        position = "left",
        width = 35,
      },
    },
    keymaps = {
      view = {
        { "n", "<tab>", "<cmd>lua require('diffview.actions').select_next_entry()<CR>", { desc = "Next file" } },
        {
          "n",
          "<s-tab>",
          "<cmd>lua require('diffview.actions').select_prev_entry()<CR>",
          { desc = "Previous file" },
        },
        { "n", "gf", "<cmd>lua require('diffview.actions').goto_file()<CR>", { desc = "Goto file" } },
        { "n", "<C-w><C-f>", "<cmd>lua require('diffview.actions').goto_file_split()<CR>", { desc = "Goto file split" } },
        { "n", "<C-w>gf", "<cmd>lua require('diffview.actions').goto_file_tab()<CR>", { desc = "Goto file tab" } },
        { "n", "[x", "<cmd>lua require('diffview.actions').prev_conflict()<CR>", { desc = "Previous conflict" } },
        { "n", "]x", "<cmd>lua require('diffview.actions').next_conflict()<CR>", { desc = "Next conflict" } },
      },
      file_panel = {
        close_panel,
        { "n", "j", "<cmd>lua require('diffview.actions').next_entry()<CR>", { desc = "Next entry" } },
        { "n", "k", "<cmd>lua require('diffview.actions').prev_entry()<CR>", { desc = "Previous entry" } },
        { "n", "<cr>", "<cmd>lua require('diffview.actions').select_entry()<CR>", { desc = "Select entry" } },
        { "n", "o", "<cmd>lua require('diffview.actions').select_entry()<CR>", { desc = "Select entry" } },
        { "n", "R", "<cmd>lua require('diffview.actions').refresh_files()<CR>", { desc = "Refresh files" } },
        { "n", "<tab>", "<cmd>lua require('diffview.actions').select_next_entry()<CR>", { desc = "Next file" } },
        {
          "n",
          "<s-tab>",
          "<cmd>lua require('diffview.actions').select_prev_entry()<CR>",
          { desc = "Previous file" },
        },
      },
      file_history_panel = {
        close_panel,
        { "n", "g!", "<cmd>lua require('diffview.actions').options()<CR>", { desc = "Options" } },
        { "n", "<cr>", "<cmd>lua require('diffview.actions').select_entry()<CR>", { desc = "Select entry" } },
        { "n", "o", "<cmd>lua require('diffview.actions').select_entry()<CR>", { desc = "Select entry" } },
        { "n", "y", "<cmd>lua require('diffview.actions').copy_hash()<CR>", { desc = "Copy hash" } },
        { "n", "j", "<cmd>lua require('diffview.actions').next_entry()<CR>", { desc = "Next entry" } },
        { "n", "k", "<cmd>lua require('diffview.actions').prev_entry()<CR>", { desc = "Previous entry" } },
        { "n", "<tab>", "<cmd>lua require('diffview.actions').select_next_entry()<CR>", { desc = "Next file" } },
        {
          "n",
          "<s-tab>",
          "<cmd>lua require('diffview.actions').select_prev_entry()<CR>",
          { desc = "Previous file" },
        },
      },
    },
    hooks = {
      diff_buf_read = function()
        -- Enable synchronized scrolling
        vim.opt_local.scrollbind = true
        vim.opt_local.cursorbind = true
      end,
    },
  },
}
