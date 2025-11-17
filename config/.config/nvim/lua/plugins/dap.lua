local function pick_script()
  local pilot = require("package-pilot")

  local current_dir = vim.fn.getcwd()
  local package = pilot.find_package_file({ dir = current_dir })

  if not package then
    vim.notify("No package.json found", vim.log.levels.ERROR)
    return require("dap").ABORT
  end

  local scripts = pilot.get_all_scripts(package)

  local label_fn = function(script)
    return script
  end

  local co, ismain = coroutine.running()
  local ui = require("dap.ui")
  local pick = (co and not ismain) and ui.pick_one or ui.pick_one_sync
  local result = pick(scripts, "Select script", label_fn)
  return result or require("dap").ABORT
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "banjo/package-pilot.nvim",
      },
    },
    opts = function()
      local dap = require("dap")
      local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

      local current_file = vim.fn.expand("%:t")

      -- js-debug-adapter for Chrome/Edge debugging
      dap.adapters["pwa-chrome"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
            "${port}",
          },
        },
      }

      -- Add new base configurations, override the default ones
      for _, language in ipairs(js_filetypes) do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
          {
            name = "tsx (" .. current_file .. ")",
            type = "node",
            request = "launch",
            program = "${file}",
            runtimeExecutable = "tsx",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
            skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
          },
          {
            name = "pick script (npm)",
            type = "pwa-node",
            request = "launch",
            runtimeExecutable = "npm",
            cwd = "${workspaceFolder}",
            runtimeArgs = { "run", pick_script },
            skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
            sourceMaps = true,
            protocol = "inspector",
            console = "integratedTerminal",
            autoAttachChildProcesses = true,
            sourceMapPathOverrides = {
              ["ui-server/insights-web/src/*"] = "${workspaceFolder}/packages/insights-web/src/*",
              ["ui-server/insights-web/*"] = "${workspaceFolder}/packages/insights-web/src/*",
            },
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
            outFiles = {
              "${workspaceFolder}/**/*.js",
              "!**/node_modules/**",
            },
          },
        }
      end
    end,
  },
}
