return {
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        opts = {
            options = {
                theme = "auto",
                globalstatus = true,
                section_separators = "",
                component_separators = "|",
                disabled_filetypes = { statusline = { "neo-tree" } },
            },
        },
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "modern",
        },
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        cmd = "Neotree",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        opts = {
            close_if_last_window = true,
            filesystem = {
                filtered_items = { hide_dotfiles = false, hide_gitignored = false },
                follow_current_file = { enabled = true },
                use_libuv_file_watcher = true,
            },
            window = {
                width = 32,
            },
        },
    },
}
