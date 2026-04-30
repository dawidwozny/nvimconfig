---@type LazySpec
return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource true",
    opts = {
      provider = "copilot",
      providers = {
        copilot = {
          model = "claude-sonnet-4",
        },
      },
      behaviour = {
        auto_suggestions = false,
        auto_set_keymaps = true,
        auto_set_highlight_group = true,
      },
      windows = {
        position = "right",
        width = 40,
      },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "zbirenbaum/copilot.lua",
    },
  },
}
