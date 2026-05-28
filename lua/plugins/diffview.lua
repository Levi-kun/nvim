return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  opts = {
    enhanced_diff_hl = true, -- Highly optimized, crisp code highlighting in diff splits
    use_icons = true,        -- Utilizes your devicons/mini-icons setup
  },
  keys = {
    -- Smart toggle function: Opens if closed, closes if open
    {
      "<leader>gd",
      function()
        if next(require("diffview.lib").views) == nil then
          vim.cmd("DiffviewOpen")
        else
          vim.cmd("DiffviewClose")
        end
      end,
      desc = "Toggle Git Diffview",
    },
    {
      "<leader>gh",
      "<cmd>DiffviewFileHistory %<cr>",
      desc = "Git File History (Current File)",
    },
  },
}
