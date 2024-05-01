return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local ensure_installed = {
			"pyright",
			"yamlls",
			"helm_ls",
			"jsonls",
			"tsserver",
			"bashls",
			"lua_ls",
			"taplo",
			"terraformls",

		}

		mason.setup {}

		mason_lspconfig.setup {
			ensure_installed = ensure_installed,
		}

	end,
}
