local avante_fts = {
  Avante = true,
  AvanteInput = true,
  AvantePromptInput = true,
  AvanteSelectedCode = true,
  AvanteSelectedFiles = true,
  AvanteTodos = true,
}

---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.highlight = opts.highlight or {}
      local orig_disable = opts.highlight.disable
      opts.highlight.disable = function(lang, bufnr)
        local ft = bufnr and vim.bo[bufnr].filetype or vim.bo.filetype
        if avante_fts[ft] then return true end
        if type(orig_disable) == "function" then return orig_disable(lang, bufnr) end
        if type(orig_disable) == "table" then
          return vim.tbl_contains(orig_disable, lang) or vim.tbl_contains(orig_disable, ft)
        end
        return orig_disable == true
      end
    end,
  },
  {
    "RRethy/vim-illuminate",
    opts = function(_, opts)
      local orig_should_enable = opts.should_enable
      opts.should_enable = function(bufnr)
        if avante_fts[vim.bo[bufnr].filetype] then return false end
        if orig_should_enable then return orig_should_enable(bufnr) end
        return true
      end
    end,
  },
}
