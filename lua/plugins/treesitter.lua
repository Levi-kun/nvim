-- ~/.config/nvim/lua/plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  -- Only load when a file buffer is actually opened
  event = { "BufReadPost", "BufNewFile" }, 
  config = function()
    local configs = require("nvim-treesitter")
    configs.setup({
      ensure_installed = { "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
