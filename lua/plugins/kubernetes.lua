---@type LazySpec
return {
  {
    "ramilito/kubectl.nvim",
    version = "2.*",
    keys = {
      { "<Leader>tk", function() require("kubectl").toggle() end, desc = "Toggle Kubectl" },
    },
    build = function(plugin)
      local target_dir = plugin.dir .. "/target/release"
      vim.fn.mkdir(target_dir, "p")
      local dll_path = target_dir .. "/kubectl_client.dll"

      if vim.uv.fs_stat(dll_path) then return end

      local tag = plugin._.installed and plugin._.installed.tag or "v2.41.2"
      local url = string.format(
        "https://github.com/Ramilito/kubectl.nvim/releases/download/%s/x86_64-pc-windows-gnu.dll",
        tag
      )

      vim.notify("kubectl.nvim: downloading native binary...", vim.log.levels.INFO)
      vim.system({ "curl.exe", "-sL", "-o", dll_path, url }):wait()
      vim.notify("kubectl.nvim: native binary downloaded", vim.log.levels.INFO)
    end,
    config = function()
      local plugin_root = vim.fn.stdpath("data") .. "/lazy/kubectl.nvim"
      package.cpath = package.cpath .. ";" .. plugin_root .. "/target/release/?.dll"
      require("kubectl").setup()
    end,
  },
}
