local options = {
  ensure_installed = {
    "bash",
    "markdown",
    "cpp",
    "c",
    "make",
    "cmake",
    "lua",
    "luadoc",
    "printf",
    "vim",
    "vimdoc",
    "toml",
    "yaml",
  },

  highlight = {
    enable = true,
    use_languagetree = true,
  },

  indent = { enable = true },
}

require("nvim-treesitter.configs").setup(options)
