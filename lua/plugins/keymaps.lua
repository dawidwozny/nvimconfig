---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          ["<Leader>tl"] = false,
          ["<Leader>tg"] = {
            function()
              local astro = require("astrocore")
              local worktree = astro.file_worktree()
              local flags = worktree and (" --work-tree=%s --git-dir=%s"):format(worktree.toplevel, worktree.gitdir) or ""
              astro.toggle_term_cmd({ cmd = "lazygit " .. flags, direction = "float" })
            end,
            desc = "ToggleTerm lazygit",
          },
        },
      },
    },
  },
}
