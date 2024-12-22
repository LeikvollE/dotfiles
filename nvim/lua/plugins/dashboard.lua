return {
  {
    "snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
          VIM - Vi IMproved
          ]],
        },
        sections = {
          { section = "header" },
          { icon = "", section = "keys", title = "Keymaps", indent = 1, padding = 1},
          { icon = "", section = "projects", title = "Projects", indent = 1, padding = 1},
          { icon = "", section = "recent_files", title = "Recent Files", indent = 1, padding = 1 },
          { section = "startup" }
        },
      },
    },
  },
}
