-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local g = vim.g
local opt = vim.opt

opt.ruler = true
opt.incsearch = true
opt.hlsearch = true
opt.scrolloff = 5
opt.wildmenu = true
opt.showcmd = true
opt.autoindent = true
opt.wrap = true

-- add python venv
local venv = vim.fn.expand("$HOME/zdotdir/.venv/bin/python")
g.python_host_prog = venv
g.python3_host_prog = venv

-- LazyVim options
g.root_spec = { "cwd" }

-- LazyVim auto format
vim.g.autoformat = false
