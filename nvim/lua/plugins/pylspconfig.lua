return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "standard",
              },
            },
          },
        },
        ruff = {
          init_options = {
            settings = {
              lint = {
                enable = true,
              },
            },
          },
        },
      },
    },
  },
}
