return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
		"3rd/image.nvim",
	},
	lazy = false,
	priority = 1000,
	config = function()
		vim.fn.sign_define("DiagnosticSignError",
        {text = " ", texthl = "DiagnosticSignError"})
      vim.fn.sign_define("DiagnosticSignWarn",
        {text = " ", texthl = "DiagnosticSignWarn"})
      vim.fn.sign_define("DiagnosticSignInfo",
        {text = " ", texthl = "DiagnosticSignInfo"})
      vim.fn.sign_define("DiagnosticSignHint",
        {text = "󰌵", texthl = "DiagnosticSignHint"})

		local neotree = require("neo-tree")

		neotree.setup {
			default_component_configs = {
				indent = {
					with_expanders = true
				}
			},
			window = {
				position = "current",
			},
			filesystem = {
				filtered_items = {
					hide_dotfiles = false,
				}
			},
			source_selector = {
				winbar = true,
			},
			event_handlers = {
				{
					event = "neo_tree_buffer_enter",
					handler = function()
						vim.cmd [[
							setlocal number
							setlocal relativenumber
							setlocal cursorline
							]]
					end,
				}
			}
		}

		vim.cmd([[:Neotree source=filesystem position=current reveal=true toggle]])
	end,
	keys = {
		{ "<leader>ef", ":Neotree source=filesystem position=current reveal=true toggle<CR>", { noremap = true } },
		{ "<leader>eb", ":Neotree source=buffers position=current reveal=true toggle<CR>", { noremap = true } },
		{ "<leader>eg", ":Neotree source=git_status position=current reveal=true toggle<CR>", { noremap = true } },
	},
}
