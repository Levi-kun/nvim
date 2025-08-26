require("nvim-tree").setup {
        view = {
          width = 35,
          side = "left",
          number = true,
        },
        renderer = {
          group_empty = true,
          add_trailing = true,
          hidden_display = "all",
          highlight_git = "name",
          highlight_modified = "name",
         },
        git = {
          enable = true,
          ignore = false,
        },
        filters = {
          dotfiles = false, -- Show dotfiles
        },
      }

