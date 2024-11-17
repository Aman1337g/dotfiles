require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Custom keymappings

-- autocompletion
map("n", "<leader>p", '<cmd>lua require("cmp").setup { enabled = true }<cr>', { desc = "Enable completion" })

map("n", "<leader>P", '<cmd>lua require("cmp").setup { enabled = false }<cr>', { desc = "Disable completion" })
-- lsp
map("n", "<leader>S", "<cmd>LspStop<CR>", { desc = "LspStop" })
map("n", "<leader>s", "<cmd>LspStart<CR>", { desc = "LspStart" })

-- telescope symbols
map("n", "<leader>fs", "<cmd>Telescope symbols<CR>", { desc = "Find Symbols" })

-- markdown preview in qutebrowser
map("n", "<leader>mp", function()
  -- Start MarkdownPreview in the background
  vim.fn.jobstart "MarkdownPreview"

  -- Use vim.defer_fn to delay qutebrowser opening
  vim.defer_fn(function()
    -- After 2 seconds, open qutebrowser
    vim.fn.jobstart "/home/aman/qutebrowser/.venv/bin/python3 -m qutebrowser http://localhost:8177"
  end, 2000) -- 2000 milliseconds = 2 seconds
end, { noremap = true, silent = true, desc = "markdown preview in qutebrowser" })
