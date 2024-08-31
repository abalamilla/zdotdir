return {
	{
		"williamboman/mason.nvim",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			local mason = require("mason")
			local mason_lspconfig = require("mason-lspconfig")
			local lsp_ensure_installed = {
				"pyright",
				"yamlls",
				"helm_ls",
				"jsonls",
				"tsserver",
				"bashls",
				"lua_ls",
				"taplo",
				"terraformls",
				"markdown_oxide",
				"gopls",
				"rust_analyzer",
				"jdtls",
				"clojure_lsp",
			}

			mason.setup({})

			mason_lspconfig.setup({
				ensure_installed = lsp_ensure_installed,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			local util = require("lspconfig.util")
			local configs = require("lspconfig.configs")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			lspconfig.pyright.setup({ capabilities = capabilities })
			lspconfig.yamlls.setup({ capabilities = capabilities })
			lspconfig.helm_ls.setup({ capabilities = capabilities })
			lspconfig.jsonls.setup({ capabilities = capabilities })
			lspconfig.tsserver.setup({ capabilities = capabilities })
			lspconfig.bashls.setup({ capabilities = capabilities })
			lspconfig.lua_ls.setup({ capabilities = capabilities })
			lspconfig.taplo.setup({ capabilities = capabilities })
			lspconfig.terraformls.setup({ capabilities = capabilities })
			lspconfig.markdown_oxide.setup({ capabilities = capabilities })
			lspconfig.gopls.setup({ capabilities = capabilities })
			lspconfig.rust_analyzer.setup({ capabilities = capabilities })
			lspconfig.jdtls.setup({ capabilities = capabilities })
			lspconfig.clojure_lsp.setup({ capabilities = capabilities })

			if not configs.kcl then
				configs.kcl = {
					default_config = {
						cmd = { "kcl-language-server" },
						filetypes = { "kcl" },
						root_dir = util.root_pattern(".git"),
					},
				}
			end

			lspconfig.kcl.setup({})
		end,
		keys = {
			{ "K", ":lua vim.lsp.buf.hover()<CR>", "Hover" },
			{ "gd", ":lua vim.lsp.buf.definition()<CR>", "Definition" },
			{ "gD", ":lua vim.lsp.buf.declaration()<CR>", "Declaration" },
			{ "gr", ":lua vim.lsp.buf.references()<CR>", "References" },
			{ "gi", ":lua vim.lsp.buf.implementation()<CR>", "Implementation" },
			{ "gs", ":lua vim.lsp.buf.signature_help()<CR>", "Signature Help" },
			{ "gt", ":lua vim.lsp.buf.type_definition()<CR>", "Type Definition" },
			{ "gR", ":lua vim.lsp.buf.rename()<CR>", "Rename" },
			{ "<leader>wa", ":lua vim.lsp.buf.add_workspace_folder()<CR>", "Add Workspace Folder" },
			{ "<leader>wr", ":lua vim.lsp.buf.remove_workspace_folder()<CR>", "Remove Workspace Folder" },
			{
				"<leader>wl",
				":lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
				"List Workspace Folders",
			},
			{ "<leader>ca", ":lua vim.lsp.buf.code_action()<CR>", "Code Action" },
		},
	},
}
