return {
  {
    "AlexvZyl/nordic.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = {
        bg = true,
        float = true,
      },
      italic_comments = true,
      bright_border = false,
      reduced_blue = true,
    },
  },
  -- Tell LazyVim to use Nordic as the default colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nordic",
    },
  },
}
