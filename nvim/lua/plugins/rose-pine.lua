return {
	"rose-pine/nvim",
	name = "rose-pine",
	config = function()
		require("rose-pine").setup({
			variant = "main",
		})
		vim.cmd.colorscheme("rose-pine")
	end
}
