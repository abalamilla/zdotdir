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
    picker = {
      sources = {
        explorer = {
          layout = { layout = { position = "right" } },
          auto_close = true,
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
              },
            },
          },
        },
        files = {
          hidden = true,
          follow = true,
          filter = {
            cwd = true,
          },
        },
      },
    },
  },
}
