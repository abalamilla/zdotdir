return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")

		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.prettier,
				null_ls.builtins.formatting.shfmt.with({ filetypes = { "sh", "zsh" } }),
				null_ls.builtins.formatting.cljstyle,

				-- null_ls.builtins.diagnostics.eslint_d,
				null_ls.builtins.diagnostics.clj_kondo,
			},
		})

		vim.keymap.set("n", "<leader>df", vim.lsp.buf.format, {})
	end,
}
