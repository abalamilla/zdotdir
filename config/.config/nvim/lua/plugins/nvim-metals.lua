return {
  {
    "scalameta/nvim-metals",
    -- Override LazyVim's telescope-based metals commands key (telescope not installed)
    keys = {
      {
        "<leader>me",
        function()
          require("metals").commands()
        end,
        desc = "Metals commands",
      },
    },
    -- Extend LazyVim's lang.scala opts (statusBarProvider, settings, on_attach already configured there)
    opts = function(_, metals_config)
      metals_config.capabilities = require("blink.cmp").get_lsp_capabilities(metals_config.capabilities)
      -- Run from $HOME to use global .tool-versions (Java 26), not the project's (may be Java 8/11)
      local java_home = vim.fn.trim(
        vim.fn.system("cd ~ && " .. vim.fn.expand("~/.local/bin/mise") .. " where java 2>/dev/null")
      )
      if java_home ~= "" then
        metals_config.cmd_env = { JAVA_HOME = java_home }
      end
      return metals_config
    end,
  },
  -- Put testTarget first: runOrTestFile fails for ScalaTest FunSpec on Scala 2.11
  -- because metals' semanticdb static analysis doesn't recognize FunSpec+@RunWith as a test class.
  -- testTarget uses Bloop BSP discovery (same path as <leader>me Select Test Suite).
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      dap.configurations.scala = {
        {
          type = "scala",
          request = "launch",
          name = "Test Target",
          metals = { runType = "testTarget" },
        },
        {
          type = "scala",
          request = "launch",
          name = "RunOrTest",
          metals = { runType = "runOrTestFile" },
        },
      }
    end,
  },
}