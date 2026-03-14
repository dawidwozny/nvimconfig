return {
  "nvim-neotest/neotest",
  dependencies = {
    "rouge8/neotest-rust",
  },
  opts = function(_, opts)
    if not opts.adapters then opts.adapters = {} end
    table.insert(opts.adapters, require "neotest-rust")
  end,
}
