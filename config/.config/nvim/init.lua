-- config for neovim
vim.o.number = true
vim.o.relativenumber = true
vim.o.ruler = true
vim.o.incsearch = true
vim.o.hlsearch = true
vim.o.scrolloff = 5
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.wildmenu = true
vim.o.showcmd = true
vim.o.linebreak = true
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.backupcopy = "yes"

-- clear highlighting on esc in normal mode
vim.api.nvim_set_keymap("n", "<esc>", ":noh<cr>", { noremap = true, silent = true })

-- supress arrow keys all modes
vim.api.nvim_set_keymap("n", "<up>", "<nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<down>", "<nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<left>", "<nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<right>", "<nop>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("i", "<up>", "<nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<down>", "<nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<left>", "<nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<right>", "<nop>", { noremap = true, silent = true })

-- add python venv
local py3nvim = vim.fn.expand("$HOME/zdotdir/py3nvim/bin/python")
vim.g.python_host_prog = py3nvim
vim.g.python3_host_prog = py3nvim

require("config.lazy")

