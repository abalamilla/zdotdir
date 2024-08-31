return {
	"kcl-lang/kcl.nvim",
	init = function()
		vim.api.nvim_command([[autocmd BufNewFile,BufRead *.k set filetype=kcl]])
	end,
	ft = {
		"kcl"
	}
}
