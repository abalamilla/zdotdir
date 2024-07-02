return {
	"neovim/nvim-lspconfig",
	config = function()
		local lspconfig = require("lspconfig")
		local util = require("lspconfig.util")
		local configs = require("lspconfig.configs")

		lspconfig.pyright.setup {}
		lspconfig.yamlls.setup {}
		lspconfig.helm_ls.setup {}
		lspconfig.jsonls.setup {}
		lspconfig.tsserver.setup {}
		lspconfig.bashls.setup {}
		lspconfig.lua_ls.setup {}
		lspconfig.taplo.setup {}
		lspconfig.terraformls.setup {}
		lspconfig.markdown_oxide.setup {}
		lspconfig.gopls.setup {}

		if not configs.kcl then
			configs.kcl = {
				default_config = {
					cmd = { "kcl-language-server" },
					filetypes = { "kcl" },
					root_dir = util.root_pattern(".git"),
				},
			}
		end

		lspconfig.kcl.setup {}
	end,
}

