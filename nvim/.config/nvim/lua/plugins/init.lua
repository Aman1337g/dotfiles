return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "configs.treesitter"
    end,
  },

  {
    "stevearc/conform.nvim",
    -- event = "BufWritePre", -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "html-lsp",
        "css-lsp",
        "prettierd",
        "pyright",
        "clangd",
        "eslint-lsp",
        "typescript-language-server",
        "clang-format",
        "isort",
        "black",
        "marksman",
      },
    },
  },
  {
    "shortcuts/no-neck-pain.nvim",
    cmd = "NoNeckPain",
    keys = { { "<leader>nn", "<cmd>NoNeckPain<cr>", desc = "[N]o [N]eckpain" } },
    opts = {},
  },
  {
    "nvim-telescope/telescope-symbols.nvim",
    event = { "BufReadPost" },
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    config = function()
      require "configs.markdown-preview"
    end,
  },
}
