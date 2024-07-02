return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
		"3rd/image.nvim",
	},
	config = function()
		local neotree = require("neo-tree")

		neotree.setup {
			window = {
				position = "current",
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
	end,
	keys = {
		{ "<leader>ef", ":Neotree source=filesystem position=current reveal=true toggle<CR>", { noremap = true } },
		{ "<leader>eb", ":Neotree source=buffers position=current reveal=true toggle<CR>", { noremap = true } },
		{ "<leader>eg", ":Neotree source=git_status position=current reveal=true toggle<CR>", { noremap = true } },
	},
}
