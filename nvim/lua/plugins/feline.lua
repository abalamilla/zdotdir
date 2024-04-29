return {
	"freddiehaddad/feline.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"lewis6991/gitsigns.nvim",
	},
	init = function()
		vim.opt.termguicolors = true
	end,
	opts = {},
	config = function(_, opts)
		require("feline").setup()
		require("feline").winbar.setup()
	end,
}
