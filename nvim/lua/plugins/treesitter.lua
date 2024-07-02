return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local config = require("nvim-treesitter.configs")

		config.setup {
			ensure_installed = {
				"bash",
				"json",
				"lua",
				"python",
				"typescript",
				"yaml",
				"vim",
				"vimdoc",
				"rust",
				"ruby",
			},
			highlight = {
				enable = true,
			},
			indent = {
				enable = true,
			},
			sync_install = false,
		}
	end,
}
