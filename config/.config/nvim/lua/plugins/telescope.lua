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
			{ "<leader>tf", "<cmd>Telescope find_files<cr>" },
			{ "<leader>tb", "<cmd>Telescope buffers<cr>" },
			{ "<leader>tg", "<cmd>Telescope live_grep<cr>" },
			{ "<leader>tw", "<cmd>Telescope grep_string<cr>" },
			{ "<leader>ty", "<cmd>Telescope neoclip<cr>" },
			{ "<leader>tr", "<cmd>Telescope registers<cr>" },
			{ "<leader>tq", "<cmd>Telescope quickfix<cr>" },
			{ "<leader>tQ", "<cmd>Telescope quickfixhistory<cr>" },
			{ "<leader>tk", "<cmd>Telescope keymaps<cr>" },
			{ "<leader>tt", "<cmd>Telescope treesitter<cr>" },
		},
		config = function()
			local telescope = require("telescope")

			telescope.setup({
				defaults = {
					layout_strategy = "vertical",
					layout_config = {
						horizontal = {
							preview_width = 0.6,
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
				},
			})

			vim.api.nvim_create_autocmd("User", {
				pattern = "TelescopePreviewerLoaded",
				callback = function()
					vim.wo.number = true
					vim.wo.cursorline = true
					vim.wo.wrap = true
				end,
			})
		end,
	},
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
		config = function()
			require("telescope").load_extension("fzf")
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			-- This is your opts table
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
	{
		"AckslD/nvim-neoclip.lua",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("neoclip").setup()
			require("telescope").load_extension("neoclip")
		end,
	},
}
