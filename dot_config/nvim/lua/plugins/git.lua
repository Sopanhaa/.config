return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
            current_line_blame = false,
        },
    },
    {
        "kdheepak/lazygit.nvim",
        cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile" },
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open lazygit" },
        },
    },
}
