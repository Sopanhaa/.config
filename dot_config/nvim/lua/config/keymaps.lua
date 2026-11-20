local map = vim.keymap.set

-- Quality of life
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear highlights" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear highlights" })

map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Move lines in visual mode
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Keep the cursor centered while scrolling
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Paste without losing the current register
map("x", "<leader>p", '"_dP', { desc = "Paste without overwriting register" })

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Grep files" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", { desc = "Diagnostics" })

-- File explorer
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle explorer" })

-- Git mappings live in lua/plugins/git.lua so they load with lazygit.nvim
