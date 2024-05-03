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
		local nvimtree = require("nvim-tree")
		local api = require("nvim-tree.api")

		local function label(path)
			path = path:gsub(os.getenv("HOME"), "~", 1)
			return path:gsub('([a-zA-Z])[a-zA-Z0-9]+', '%1') ..
				(path:match('[a-zA-Z]([a-z0-9]*)$' or ''))
		end

		nvimtree.setup({
			disable_netrw = true,
			hijack_unnamed_buffer_when_opening = true,
			respect_buf_cwd = true,
			view = {
				cursorline = true,
				number = true,
				relativenumber = true,
				centralize_selection = true,
			},
			renderer = {
				full_name = true,
				root_folder_label = label,
				group_empty = label,
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

		local function open_nvim_tree()
			api.tree.open()
		end

		-- open nvim-tree on startup
		vim.api.nvim_create_autocmd({"VimEnter"}, { callback = open_nvim_tree })
	end,
}
