return {
	"taybart/b64.nvim",
	keys = {
		{ "<leader>be", ":lua require('b64').encode()<CR>", "b64 encode" },
		{ "<leader>bd", ":lua require('b64').decode()<CR>", "b64 decode" },
	}
}
