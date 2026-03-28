---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        -- language servers
        "docker-language-server",
        "helm-ls",
        "lua-language-server",
        "roslyn",
        "svelte-language-server",
        "vtsls",
        "yaml-language-server",

        -- formatters / linters
        "csharpier",
        "hadolint",
        "selene",
        "stylua",
        "taplo",

        -- debuggers
        "codelldb",
        "js-debug-adapter",
        "netcoredbg",
      },
    },
  },
}
