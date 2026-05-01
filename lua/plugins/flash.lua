return {
  {
    "folke/flash.nvim",
    opts = {
      modes = {
        search = {
          enabled = true,
        },
      },
      -- Make jump labels more visible
      label = {
        -- Use uppercase letters for better visibility
        uppercase = true,
        -- Style for the jump labels
        style = "overlay", -- or "inline", "eol"
      },
    },
    config = function(_, opts)
      require("flash").setup(opts)

      -- Get Catppuccin colors
      local colors = require("catppuccin.palettes").get_palette()

      -- Custom highlight groups using Catppuccin colors
      vim.api.nvim_set_hl(0, "FlashLabel", {
        fg = colors.base,      -- Dark text
        bg = colors.peach,     -- Peach background (orange-ish)
        bold = true,
        italic = false,
      })

      vim.api.nvim_set_hl(0, "FlashMatch", {
        fg = colors.mauve,     -- Purple text
        bg = "NONE",
        bold = true,
        underline = true,
      })

      vim.api.nvim_set_hl(0, "FlashCurrent", {
        fg = colors.base,      -- Dark text
        bg = colors.green,     -- Green background
        bold = true,
      })
    end,
  },
}
