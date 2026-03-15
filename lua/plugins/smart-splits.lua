-- Fast pane navigation using escape sequences instead of wezterm CLI
-- (wezterm cli process spawn is slow on Windows)
local nav_directions = {
  h = { vim_dir = "h", wez_b64 = "TGVmdA==" }, -- base64("Left")
  j = { vim_dir = "j", wez_b64 = "RG93bg==" }, -- base64("Down")
  k = { vim_dir = "k", wez_b64 = "VXA=" }, -- base64("Up")
  l = { vim_dir = "l", wez_b64 = "UmlnaHQ=" }, -- base64("Right")
}

local function navigate(key)
  local d = nav_directions[key]
  local cur_win = vim.fn.winnr()
  vim.cmd("wincmd " .. d.vim_dir)
  if vim.fn.winnr() == cur_win then
    vim.fn.chansend(vim.v.stderr, string.format("\x1b]1337;SetUserVar=WEZTERM_NAVIGATE=%s\x07", d.wez_b64))
  end
end

---@type LazySpec
return {
  {
    "mrjones2014/smart-splits.nvim",
    opts = {
      at_edge = "stop",
    },
  },
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          -- Override AstroNvim's default smart-splits mappings with fast escape-sequence navigation
          ["<C-h>"] = { function() navigate("h") end, desc = "Move to left split" },
          ["<C-j>"] = { function() navigate("j") end, desc = "Move to below split" },
          ["<C-k>"] = { function() navigate("k") end, desc = "Move to above split" },
          ["<C-l>"] = { function() navigate("l") end, desc = "Move to right split" },
          ["<A-h>"] = { function() require("smart-splits").resize_left() end, desc = "Resize split left" },
          ["<A-j>"] = { function() require("smart-splits").resize_down() end, desc = "Resize split down" },
          ["<A-k>"] = { function() require("smart-splits").resize_up() end, desc = "Resize split up" },
          ["<A-l>"] = { function() require("smart-splits").resize_right() end, desc = "Resize split right" },
        },
      },
    },
  },
}
