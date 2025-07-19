local utils = require("config.utils")

return {
  "zbirenbaum/copilot.lua",
  enabled = utils.isWorkBox and true or false,
  opts = {
    filetypes = {
      vimwiki = false,
    }
  }
}
