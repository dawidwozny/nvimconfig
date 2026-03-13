-- Vitest adapter for neotest.
-- Replaces the jest adapter (auto-added by the typescript pack) with vitest.
---@type LazySpec
return {
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      { "marilari88/neotest-vitest", config = function() end },
    },
    opts = function(_, opts)
      if not opts.adapters then
        opts.adapters = {}
      end
      -- Remove jest adapter added by the typescript pack
      for i = #opts.adapters, 1, -1 do
        if opts.adapters[i] and opts.adapters[i].name == "neotest-jest" then
          table.remove(opts.adapters, i)
        end
      end
      table.insert(opts.adapters, require("neotest-vitest")({}))
    end,
  },
}
