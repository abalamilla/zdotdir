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
                -- Send file to Claude Code
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

                    -- Get current item from picker.list
                    local item = nil
                    if picker.list then
                      -- Try _current property first
                      item = picker.list._current

                      -- If not found, try using cursor and items
                      if not item and picker.list.cursor and picker.list.items then
                        item = picker.list.items[picker.list.cursor]
                      end
                    end

                    if not item then
                      vim.notify("No item found", vim.log.levels.WARN)
                      return
                    end

                    -- Get the file path (try multiple properties)
                    local file_path = item.file or item._path or item.path
                    if not file_path then
                      vim.notify("No file path in item. Keys: " .. vim.inspect(vim.tbl_keys(item)), vim.log.levels.WARN)
                      return
                    end

                    -- Skip directories
                    if item.dir then
                      vim.notify("Cannot add directory to Claude Code", vim.log.levels.WARN)
                      return
                    end

                    -- Add the file to Claude Code using Lua API
                    local ok_cc, claudecode = pcall(require, "claudecode")
                    if ok_cc and claudecode.send_at_mention then
                      claudecode.send_at_mention(file_path)
                      vim.notify("Added to Claude Code: " .. vim.fn.fnamemodify(file_path, ":~:."), vim.log.levels.INFO)
                    else
                      vim.notify("ClaudeCode plugin not loaded", vim.log.levels.ERROR)
                    end
                  end,
                  desc = "Send to Claude Code",
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
