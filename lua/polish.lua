-- Use snacks.picker for LSP references (grr)
-- This gives a modern picker UI with live preview, instead of the default quickfix/loclist.
-- Always wins over built-in Neovim mappings by running on LspAttach.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("snacks_lsp_overrides", { clear = true }),
  callback = function(args)
    vim.keymap.set("n", "grr", function()
      require("snacks.picker").lsp_references()
    end, { buffer = args.buf, desc = "References (snacks)" })
  end,
})
