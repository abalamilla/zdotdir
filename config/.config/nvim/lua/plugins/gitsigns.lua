return {
	"lewis6991/gitsigns.nvim",
	config = function()
		require("gitsigns").setup({
			current_line_blame = true,
		})
	end,
	keys = {
		{ "<leader>gp", ":Gitsigns preview_hunk<CR>", desc = "Gitsigns preview_hunk" },
		{ "<leader>gn", ":Gitsigns next_hunk<CR>",    desc = "Gitsigns next_hunk" },
		{ "<leader>dr", ":Gitsigns reset_hunk<CR>",   desc = "Gitsigns reset_hunk" },
	},
}
