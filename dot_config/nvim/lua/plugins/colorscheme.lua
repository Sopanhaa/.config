return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        lazy = false,
        config = function()
            require("catppuccin").setup({
                flavour = "mocha",
                transparent_background = false,
                integrations = {
                    gitsigns = true,
                    neotree = true,
                    telescope = { enabled = true },
                    treesitter = true,
                    which_key = true,
                },
            })

            vim.cmd.colorscheme("catppuccin-mocha")
        end,
    },
}
