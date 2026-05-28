return {
  "MagicDuck/grug-far.nvim",
  cmd = { "GrugFar", "GrugFarWithin" },
  opts = {
    headerMaxWidth = 80,
    transient = true, -- Closes the buffer context cleanly when done
  },
  keys = {
    {
      "<leader>gR",
      function()
        require("grug-far").open({
          prefills = {
            -- Automatically seeds the current word under your cursor into the search box
            search = vim.fn.expand("<cword>"),
          },
        })
      end,
      desc = "GrugFar: Search and Replace Current Word",
    },
    {
      "<leader>gr",
      function()
        require("grug-far").open()
      end,
      desc = "GrugFar: Open Empty Search Window",
    },
  },
}
