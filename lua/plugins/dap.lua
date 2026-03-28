---@type LazySpec
return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      handlers = {
        js = function()
          local dap = require("dap")
          dap.set_log_level("TRACE")
          local js_debug_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter"

          dap.adapters["pwa-node"] = {
            type = "server",
            host = "127.0.0.1",
            port = "${port}",
            executable = {
              command = "node",
              args = { js_debug_path .. "/js-debug/src/dapDebugServer.js", "${port}", "127.0.0.1" },
            },
          }

          dap.adapters["node"] = dap.adapters["pwa-node"]

          -- Intercept dap.run for node configs: remap type and strip VS Code-specific props
          local original_run = dap.run
          dap.run = function(config, run_opts)
            if config and (config.type == "node" or config.type == "pwa-node") then
              local root = vim.fn.getcwd()
              local function resolve(val)
                if type(val) == "string" then
                  return val:gsub("%${workspaceFolder}", root)
                elseif type(val) == "table" then
                  local t = {}
                  for k, v in pairs(val) do t[k] = resolve(v) end
                  return t
                end
                return val
              end
              config = resolve(config)
              config.type = "pwa-node"
              config.console = "integratedTerminal"
              config.preLaunchTask = nil
              config.postDebugTask = nil
            end
            return original_run(config, run_opts)
          end

          dap.configurations.javascript = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch File",
              program = "${file}",
              cwd = "${workspaceFolder}",
            },
          }
          dap.configurations.typescript = dap.configurations.javascript
        end,
      },
    },
  },
}
