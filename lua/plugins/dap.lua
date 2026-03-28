---@type LazySpec
return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      handlers = {
        js = function()
          local dap = require("dap")
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
