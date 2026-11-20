-- Leader keys must be set before plugins load
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

opt.termguicolors = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.wrap = false
opt.updatetime = 250
opt.timeoutlen = 400

opt.undofile = true
opt.swapfile = false
opt.backup = false

opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.diagnostic.config({
    virtual_text = true,
    severity_sort = true,
    float = { border = "rounded" },
})
