---@type LazySpec
return {
  "catppuccin/nvim",
  name = "catppuccin",
  ---@type CatppuccinOptions
  opts = {
    integrations = {
      semantic_tokens = true,
      treesitter = true,
      native_lsp = {
        enabled = true,
      },
    },
  },
}
