print("Hello from init.lua")
-- add ZDOTDIR/nvim to runtimepath
vim.opt.rtp:prepend(vim.fn.expand("$ZDOTDIR/nvim"))

require("config.lazy")
