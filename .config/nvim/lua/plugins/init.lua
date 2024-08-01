return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncommented for format on save
    config = function()
      require "configs.conform"
    end,
  },

  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    -- See options by running
    opts = {
      filters = {
        dotfiles = false,
        -- show files even if they are git ignored
        git_ignored = false,
      },
      view = {
        side = "left",
        -- This makes sure that longest file/folder width is assumed
        -- which I like
        width = {
          max = -1,
        },
      },
    },
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "html-lsp",
        "css-lsp",
        "prettier",
        "pyright",
        "ruff",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "python",
      },
    },
  },
}
