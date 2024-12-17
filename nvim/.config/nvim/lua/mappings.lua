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
map("n", "<leader>mp", "<cmd>MarkdownPreview<CR>", { desc = " markdownpreview in qutebrowser" })

-- lua code execution
map("n", "<space><space>x", "<cmd>source %<CR>", { desc = "Executing lua code" })
map("n", "<space>l", "<cmd>:.lua<CR>", { desc = "Executing single lua line code" })
map("v", "<space>l", ":lua<CR>", { desc = "Executing selected lua code" })
