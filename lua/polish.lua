-- Override Neovim 0.11+ built-in LSP mappings with snacks.picker
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("snacks_lsp_overrides", { clear = true }),
  callback = function(args)
    vim.keymap.set("n", "grr", function()
      require("snacks.picker").lsp_references()
    end, { buffer = args.buf, desc = "References (snacks)" })
  end,
})
