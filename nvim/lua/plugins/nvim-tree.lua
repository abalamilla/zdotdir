return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{ "<leader>e", ":NvimTreeToggle<CR>", "NvimTreeToggle" },
		{ "<leader>r", ":NvimTreeRefresh<CR>", "NvimTreeRefresh" },
		{ "<leader>n", ":NvimTreeFindFile<CR>", "NvimTreeFindFile" },
	},
	config = function()
		require("nvim-tree").setup({
			disable_netrw = true,
			hijack_netrw = true,
			respect_buf_cwd = true,
			view = {
				cursorline = true,
				number = true,
				relativenumber = true,
			},
			filters = {
				git_ignored = false,
			},
			live_filter = {
				always_show_folders = false,
			},
			actions = {
				open_file = {
					quit_on_open = true,
				},
			},
		})
	end,
}