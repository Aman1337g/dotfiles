require "nvchad.mappings"

-- Add your custom mappings here
local map = vim.keymap.set

-- General
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file", silent = true })

-- Terminal mode
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Escape Terminal mode", silent = true })

-- Autocompletion
map("n", "<leader>p", '<cmd>lua require("cmp").setup { enabled = true }<CR>', { desc = "Enable completion" })
map("n", "<leader>P", '<cmd>lua require("cmp").setup { enabled = false }<CR>', { desc = "Disable completion" })

-- LSP
map("n", "<leader>s", "<cmd>LspStart<CR>", { desc = "Start LSP", silent = true })
map("n", "<leader>S", "<cmd>LspStop<CR>", { desc = "Stop LSP", silent = true })

-- Telescope
map("n", "<leader>fs", "<cmd>Telescope symbols<CR>", { desc = "Find Symbols", silent = true })

-- Markdown Preview
map("n", "<leader>mp", "<cmd>MarkdownPreview<CR>", { desc = " Preview Markdown in qutebrowser", silent = true })

-- Lua code execution
map("n", "<space><space>x", "<cmd>source %<CR>", { desc = "Execute Lua code in current file", silent = true })
map("n", "<space>l", ":lua ", { desc = "Execute Lua line interactively" })
map("v", "<space>l", ":lua<CR>", { desc = "Execute selected Lua code", silent = true })

