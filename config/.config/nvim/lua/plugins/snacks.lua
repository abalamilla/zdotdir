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
