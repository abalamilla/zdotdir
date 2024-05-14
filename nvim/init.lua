-- add python venv
local py3nvim = vim.fn.expand("$ZDOTDIR/py3nvim/bin/python")
vim.g.python_host_prog = py3nvim
vim.g.python3_host_prog = py3nvim

-- add ZDOTDIR/nvim to runtimepath
vim.opt.rtp:prepend(vim.fn.expand("$ZDOTDIR/nvim"))

require("config.lazy")
