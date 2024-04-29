return {
	"nvim-treesitter/nvim-treesitter",
	build = function()
		require("nvim-treesitter.install").update({
			with_sync = true,
			auto_install = true,
		})()
	end,
}
