return {
    {
        "stevearc/overseer.nvim",
        lazy = true,
        -- enabled = false,
        keys = {
            { "<Leader>ot", "<Cmd>OverseerToggle<CR>", desc = "Toggle task window" },
            { "<Leader>oo", "<Cmd>OverseerRun<CR>", desc = "Launch a task" },
        },
        opts = {
            strategy = {
                "toggleterm",
                open_on_start = true,
                hidden = true,
            },
            templates =  { "builtin", "cmake_config", "cmake_build" },
        },
    },
}
