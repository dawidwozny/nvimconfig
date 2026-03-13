-- .NET test adapter for neotest (NUnit/xUnit/MSTest via dotnet test).
-- Integrates with the coreclr DAP adapter already configured in csharp.lua.
---@type LazySpec
return {
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      { "Issafalcon/neotest-dotnet", config = function() end },
    },
    opts = function(_, opts)
      if not opts.adapters then
        opts.adapters = {}
      end
      table.insert(
        opts.adapters,
        require("neotest-dotnet")({
          dap = {
            adapter_name = "coreclr",
            args = { justMyCode = false },
          },
        })
      )
    end,
  },
}
