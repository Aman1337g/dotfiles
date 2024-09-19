local autocmd = vim.api.nvim_create_autocmd

autocmd("FileType", {
  pattern = { "gitcommit", "markdown" },
  callback = function()
    require("cmp").setup { enabled = false }
  end,
})
