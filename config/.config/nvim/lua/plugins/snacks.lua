local logo = [[
 ▄▄▄       ▄▄▄▄   
▒████▄    ▓█████▄ 
▒██  ▀█▄  ▒██▒ ▄██
░██▄▄▄▄██ ▒██░█▀  
 ▓█   ▓██▒░▓█  ▀█▓
 ▒▒   ▓▒█░░▒▓███▀▒
  ▒   ▒▒ ░▒░▒   ░ 
  ░   ▒    ░    ░ 
      ░  ░ ░      
                ░ 
]]

return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        header = logo,
      },
    },
    explorer = {
      replace_netrw = true,
    },
    image = {},
    picker = {
      sources = {
        explorer = {
          layout = { layout = { position = "right" } },
          on_change = function(picker)
            local cwd = picker:cwd()
            local actual_pwd = vim.fn.getcwd()

            if cwd ~= actual_pwd then
              vim.cmd("cd " .. cwd)
            end
          end,
          hidden = true,
          win = {
            list = {
              wo = {
                number = true,
                relativenumber = true,
              },
              keys = {
                -- Send file(s) to Claude Code
                ["<leader>as"] = {
                  function(self)
                    -- Get the picker from Snacks
                    local ok, snacks_picker = pcall(require, "snacks.picker")
                    if not ok then
                      vim.notify("Could not load snacks.picker", vim.log.levels.ERROR)
                      return
                    end

                    -- Get the active picker
                    local picker_result = snacks_picker.get()
                    if not picker_result then
                      vim.notify("No active picker found", vim.log.levels.WARN)
                      return
                    end

                    -- The result is an array with the actual picker at index 1
                    local picker = picker_result[1] or picker_result

                    -- Collect items to send (either selected items or current item)
                    local items = {}

                    -- Check for selected items first
                    if picker.list and picker.list.selected then
                      -- Get all selected items
                      for _, item in pairs(picker.list.selected) do
                        table.insert(items, item)
                      end
                    end

                    -- If no selected items, fall back to current item
                    if #items == 0 and picker.list then
                      local item = nil
                      -- Try _current property first
                      item = picker.list._current

                      -- If not found, try using cursor and items
                      if not item and picker.list.cursor and picker.list.items then
                        item = picker.list.items[picker.list.cursor]
                      end

                      if item then
                        table.insert(items, item)
                      end
                    end

                    if #items == 0 then
                      vim.notify("No items found", vim.log.levels.WARN)
                      return
                    end

                    -- Load ClaudeCode plugin once
                    local ok_cc, claudecode = pcall(require, "claudecode")
                    if not ok_cc or not claudecode.send_at_mention then
                      vim.notify("ClaudeCode plugin not loaded", vim.log.levels.ERROR)
                      return
                    end

                    -- Process each item
                    local sent_files = {}
                    local skipped_dirs = 0

                    for _, item in ipairs(items) do
                      -- Skip directories
                      if item.dir then
                        skipped_dirs = skipped_dirs + 1
                      else
                        -- Get the file path (try multiple properties)
                        local file_path = item.file or item._path or item.path
                        if file_path then
                          claudecode.send_at_mention(file_path)
                          table.insert(sent_files, vim.fn.fnamemodify(file_path, ":~:."))
                        end
                      end
                    end

                    -- Notify user of results
                    if #sent_files > 0 then
                      if #sent_files == 1 then
                        vim.notify("Added to Claude Code: " .. sent_files[1], vim.log.levels.INFO)
                      else
                        vim.notify("Added " .. #sent_files .. " files to Claude Code", vim.log.levels.INFO)
                      end
                    end

                    if skipped_dirs > 0 then
                      vim.notify("Skipped " .. skipped_dirs .. " directories", vim.log.levels.WARN)
                    end

                    if #sent_files == 0 and skipped_dirs == 0 then
                      vim.notify("No valid files to send", vim.log.levels.WARN)
                    end
                  end,
                  desc = "Send to Claude Code (supports multiple selections)",
                },
              },
            },
          },
        },
        files = {
          hidden = true,
          follow = true,
        },
        grep = {
          hidden = true,
        },
      },
      files = {
        ft = { "jpg", "jpeg", "png", "webp" },
        confirm = function(self, item, _)
          self:close()
          require("img-clip").paste_image({}, "./" .. item.file) -- ./ is necessary for img-clip to recognize it as path
        end,
      },
    },
    statuscolumn = {
      enabled = true,
    },
    words = {
      enabled = true,
    },
  },
}
