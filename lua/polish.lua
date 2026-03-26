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

-- neotest-dotnet compatibility patches for Neovim 0.10+/Windows
-- neotest-dotnet uses iter_matches which returns table-wrapped nodes in Neovim 0.10+,
-- and the neotest subprocess RPC channel dies on Windows.
do
  local function normalize_windows_path(path)
    if type(path) ~= "string" or path == "" or vim.fn.has("win32") ~= 1 then
      return path
    end
    return vim.fn.fnamemodify(path:gsub("/", "\\"), ":p")
  end

  -- Fix 1: Disable subprocess on Windows (RPC channel dies)
  if vim.fn.has("win32") == 1 then
    pcall(vim.treesitter.language.register, "c_sharp", "cs")
    local lib_ok, lib = pcall(require, "neotest.lib")
    if lib_ok then
      lib.subprocess.init = function() end
      lib.subprocess.enabled = function()
        return false
      end
      local orig_real = lib.files.path.real
      lib.files.path.real = function(path)
        local real_path, exists = orig_real(path)
        return normalize_windows_path(real_path), exists
      end
      lib.files.parent = function(path)
        return vim.fn.fnamemodify(normalize_windows_path(path), ":p:h")
      end
    end

    local neotest_ok, neotest = pcall(require, "neotest")
    if neotest_ok and neotest.run and neotest.run.get_tree_from_args then
      local _, client = debug.getupvalue(neotest.run.get_tree_from_args, 1)
      if client then
        local orig_get_position = client.get_position
        client.get_position = function(self, position_id, args)
          return orig_get_position(self, normalize_windows_path(position_id), args)
        end

        local orig_get_nearest = client.get_nearest
        client.get_nearest = function(self, file_path, row, args)
          return orig_get_nearest(self, normalize_windows_path(file_path), row, args)
        end

        local orig_set_focused_file = client._set_focused_file
        client._set_focused_file = function(self, path)
          return orig_set_focused_file(self, normalize_windows_path(path))
        end
      end
    end
  end

  -- Fix 2: Patch build_position on nunit/mstest/xunit to handle table-wrapped nodes
  for _, fw in ipairs({ "nunit", "mstest", "xunit" }) do
    local ok, mod = pcall(require, "neotest-dotnet." .. fw)
    if ok and mod.build_position then
      local orig_build = mod.build_position
      mod.build_position = function(file_path, source, captured_nodes, ...)
        local unwrapped = {}
        for k, v in pairs(captured_nodes) do
          unwrapped[k] = type(v) == "table" and v[1] or v
        end
        local orig_gnt = vim.treesitter.get_node_text
        local orig_qp = vim.treesitter.query.parse
        vim.treesitter.get_node_text = function(node, src, o)
          if type(node) == "table" then node = node[1] end
          if not node then return "" end
          return orig_gnt(node, src, o)
        end
        vim.treesitter.query.parse = function(lang, qs)
          local q = orig_qp(lang, qs)
          local orig_iter = q.iter_matches
          q.iter_matches = function(self, node, src, start, stop, iopts)
            iopts = iopts or {}
            iopts.all = false
            return orig_iter(self, node, src, start, stop, iopts)
          end
          return q
        end
        local success, result = pcall(orig_build, file_path, source, unwrapped, ...)
        vim.treesitter.get_node_text = orig_gnt
        vim.treesitter.query.parse = orig_qp
        if not success then error(result) end
        return result
      end
    end
  end

  -- Fix 3: Patch framework-discovery to unwrap nodes
  local fd_ok, fd = pcall(require, "neotest-dotnet.framework-discovery")
  if fd_ok and fd.get_test_framework_utils_from_source then
    local orig_get_fw = fd.get_test_framework_utils_from_source
    fd.get_test_framework_utils_from_source = function(source, custom_attrs)
      local orig_gnt = vim.treesitter.get_node_text
      vim.treesitter.get_node_text = function(node, src, o)
        if type(node) == "table" then node = node[1] end
        if not node then return "" end
        return orig_gnt(node, src, o)
      end
      local success, result = pcall(orig_get_fw, source, custom_attrs)
      vim.treesitter.get_node_text = orig_gnt
      if not success then error(result) end
      return result
    end
  end
end
