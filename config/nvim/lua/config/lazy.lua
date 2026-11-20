-- Bootstrap lazy.nvim, then load every spec in lua/plugins/
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local repo = "https://github.com/folke/lazy.nvim.git"
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { import = "plugins" },
}, {
    checker = { enabled = false },
    change_detection = { notify = false },
    install = { colorscheme = { "catppuccin-mocha", "habamax" } },
})
