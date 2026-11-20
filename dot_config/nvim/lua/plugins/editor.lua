return {
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            defaults = {
                prompt_prefix = "  ",
                selection_caret = "  ",
                path_display = { "smart" },
                file_ignore_patterns = { "^.git/", "node_modules/" },
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "bash",
                    "c",
                    "fish",
                    "go",
                    "html",
                    "javascript",
                    "json",
                    "lua",
                    "markdown",
                    "markdown_inline",
                    "python",
                    "rust",
                    "toml",
                    "tsx",
                    "typescript",
                    "vim",
                    "vimdoc",
                    "yaml",
                },
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },
    {
        "numToStr/Comment.nvim",
        event = "VeryLazy",
        opts = {},
    },
}
