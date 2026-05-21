-- ~/.config/nvim/lua/plugins/nvim-tree-explore.lua
return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- Loads your file icons smoothly
  },
  init = function()
    -- Disable netrw entirely before the plugin loads
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  opts = {
    -- Put any custom nvim-tree options here
    view = {
      width = 30,
      side = "left",
    },
    filters = {
      dotfiles = false,
    },
  },
}
