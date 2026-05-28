return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    dashboard = { 
      enabled = true,
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "recent_files", icon = " ", title = "Recent Files", padding = 1 },
        { section = "projects", icon = " ", title = "Projects", padding = 1 },
        { section = "startup" },
      },
    },
    notifier = { 
      enabled = true,
      timeout = 3000,
    },
    indent = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = false }, -- Keeping this explicitly dead for maximum speed
    quickfile = { enabled= true },
    words = { enabled = true },
    -- ==========================================================================
    -- THE FIX: Bring back your gutter signs natively
    -- ==========================================================================
    git = { enabled = true }, -- Instantly restores git diff icons in the gutter
    statuscolumn = { enabled = true },
  },
  keys = {
    { "<leader>nh", function() Snacks.notifier.show_history() end, desc = "Notification History" },
  },
}


