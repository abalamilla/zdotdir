return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.6",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope-fzf-native.nvim",
		},
		keys = {
			{ "<leader>f", "<cmd>Telescope find_files<cr>" },
			{ "<leader>b", "<cmd>Telescope buffers<cr>" },
			{ "<leader>g", "<cmd>Telescope live_grep<cr>" },
		},
		config = function()
			local telescope = require("telescope")

			telescope.setup {
				defaults = {
					layout_config = {
						horizontal = {
							preview_cutoff = 0,
						},
					},
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--hidden",
						"--glob=!.git/",
					},
				},
				pickers = {
					find_files = {
						hidden = true,
					},
				}
			}
		end,
	},
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = 'make',
		config = function()
			require('telescope').load_extension('fzf')
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			-- This is your opts table
			require("telescope").setup {
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown {}
					}
				}
			}
			require("telescope").load_extension("ui-select")
		end,
	}
}
