---@type LazySpec
return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.registries = opts.registries or { "github:mason-org/mason-registry" }
      if not vim.tbl_contains(opts.registries, "github:Crashdummyy/mason-registry") then
        table.insert(opts.registries, "github:Crashdummyy/mason-registry")
      end
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed or {}, {
        "roslyn",
        "csharpier",
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed or {}, { "c_sharp" })
      end
    end,
  },
  {
    "seblyng/roslyn.nvim",
    init = function()
      vim.lsp.config("roslyn", {
        settings = {
          ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "fullSolution",
            dotnet_compiler_diagnostics_scope = "fullSolution",
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
            dotnet_enable_tests_code_lens = true,
          },
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
          },
        },
      })
    end,
    ---@type RoslynNvimConfig
    opts = {
      broad_search = true,
      lock_target = true,
      config = {
        on_attach = function(client, bufnr)
          if client.server_capabilities.semanticTokensProvider then
            vim.lsp.semantic_tokens.start(bufnr, client.id)
          end
        end,
      },
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed or {}, { "coreclr" })
    end,
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    config = function(plugin, opts)
      require("astronvim.plugins.configs.nvim-dap")(plugin, opts)

      local dap = require "dap"
      -- dap.set_log_level("TRACE")

      dap.adapters.coreclr = {
        type = "executable",
        command = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg/netcoredbg.exe",
        args = { "--interpreter=vscode" },
      }

      -- Fix breakpoint source paths: nvim sends forward slashes but netcoredbg needs backslashes on Windows
      local original_run = dap.run
      dap.run = function(config, run_opts)
        if config and config.type == "coreclr" then
          local root = vim.fn.getcwd()
          local function resolve(val)
            if type(val) == "string" then
              return val:gsub("%${workspaceFolder}", root):gsub("%${fileDirname}", vim.fn.expand("%:p:h"))
            elseif type(val) == "table" then
              local t = {}
              for k, v in pairs(val) do t[k] = resolve(v) end
              return t
            end
            return val
          end
          config = resolve(config)
          config.justMyCode = false
          config.preLaunchTask = nil
          config.postDebugTask = nil
          config.console = nil
          config.serverReadyAction = nil
          config.sourceFileMap = nil
        end
        return original_run(config, run_opts)
      end

      -- Fix Windows path separators: netcoredbg needs backslashes but Neovim sends forward slashes
      -- Intercept the session's request method to fix paths in setBreakpoints
      dap.listeners.after.event_initialized["fix-win-paths"] = function(session)
        local orig_request = session.request
        session.request = function(self, command, arguments, callback)
          if command == "setBreakpoints" and arguments and arguments.source and arguments.source.path then
            arguments.source.path = arguments.source.path:gsub("/", "\\")
            if arguments.source.name then
              arguments.source.name = arguments.source.name:gsub("/", "\\")
            end
          end
          return orig_request(self, command, arguments, callback)
        end
        -- Re-send breakpoints now with fixed paths
        local bps = require("dap.breakpoints").get()
        if vim.tbl_count(bps) > 0 then
          session:set_breakpoints(bps)
        end
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        cs = { "csharpier" },
      },
    },
  },
}
