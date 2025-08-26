return {
  "allaman/emoji.nvim",
  dependencies = {
    -- util for handling paths
    "nvim-lua/plenary.nvim",
    -- optional for nvim-cmp integration
    "hrsh7th/nvim-cmp",
    -- optional for telescope integration
    "nvim-telescope/telescope.nvim",
    -- optional for fzf-lua integration via vim.ui.select
    "ibhagwan/fzf-lua",
  },
   event = 'InsertEnter',
  opts = {
    -- default is false, also needed for blink.cmp integration!
    enable_cmp_integration = true,


 
  }
}
