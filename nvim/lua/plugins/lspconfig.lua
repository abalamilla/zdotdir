return {
	"neovim/nvim-lspconfig",
	config = function()
		local lspconfig = require("lspconfig")

		--lspconfig.kcl.setup {}
		lspconfig.pyright.setup {}
		lspconfig.yamlls.setup {}
		lspconfig.helm_ls.setup {}
		lspconfig.jsonls.setup {}
		lspconfig.tsserver.setup {}
		lspconfig.bashls.setup {}
		lspconfig.lua_ls.setup {}
		lspconfig.taplo.setup {}
		lspconfig.terraformls.setup {}

	end,
}

