return {

    -- make tables
    {
        "dhruvasagar/vim-table-mode",
        keys = {
            { "<Leader>||", desc = "Toggle table mode" },
            { "<Leader><Bar>T", desc = "Convert selection into table (ask)" },
            { "<Leader><Bar>t", desc = "Convert selection into table (,)" },
            { "<Leader><Bar>a", desc = "Align table" },
            { "<Leader><Bar>d", desc = "Delete row" },
            { "<Leader><Bar>D", desc = "Delete column" },
            { "<Leader><Bar>I", desc = "Insert column Before" },
            { "<Leader><Bar>i", desc = "Insert column After" },
        },
        cmd = { "TableModeToggle", "TalbeModeEnable", "Tableize", "TableModeRealign" },
        init = function()
            vim.g.table_mode_corner = "|"
            vim.g.table_mode_map_prefix = "<Leader><Bar>"
            vim.g.table_mode_toggle_map = "<Bar>"
            vim.g.table_mode_realign_map = "<Leader><Bar>a"
            vim.g.table_mode_delete_row_map = "<Leader><Bar>d"
            vim.g.table_mode_delete_column_map = "<Leader><Bar>D"
            vim.g.table_mode_insert_column_before_map = "<Leader><Bar>I"
            vim.g.table_mode_insert_column_after_map = "<Leader><Bar>i"
            vim.g.table_mode_tableize_map = "<Leader><Bar>t"
            vim.g.table_mode_tableize_d_map = "<Leader><Bar>T"
        end,
    },

    -- better matchit
    {
        "andymass/vim-matchup",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            vim.g.matchup_matchparen_offscreen = { method = "popup" }
            vim.g.matchup_surround_enabled = 1
        end
    },

    -- Automatic insertion and deletion of a pair of characters
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({
                check_ts = true,
                -- to make backspace work in some situations inside prompts and popups
                disable_filetype = {
                    "clap_input",
                    "dropbar_menu",
                    "guihua",
                    "guihua_rust",
                    "neo-tree",
                    "neo-tree-popup",
                    "prompt",
                    "spectre_panel",
                    "TelescopePrompt",
                },
            })
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
    },

    -- Smart and powerful comment plugin for neovim
    {
        "numToStr/Comment.nvim",
        keys = {
            "gcc",
            "gbc",
            {
                "<M-x>",
                function()
                    require("Comment.api").toggle.linewise.current()
                end,
                desc = "Toggle comment",
                mode = {"n", "i"}
            },
            {
                "<M-x>",
                function()
                    local u = require("config.utils")
                    vim.api.nvim_feedkeys(u.esc, "nx", false)
                    require("Comment.api").toggle.linewise(vim.fn.visualmode())
                end,
                desc = "Toggle comment (linewise)",
                mode = "v",
            },
            {
                "<M-y>",
                function()
                    local u = require("config.utils")
                    vim.api.nvim_feedkeys(u.esc, "nx", false)
                    require("Comment.api").toggle.blockwise(vim.fn.visualmode())
                end,
                desc = "Toggle comment (blockwise)",
                mode = "v",
            },
        },
        config = true
    },

    -- A breadcrumb bar showing symbols
    {
        "Bekaboo/dropbar.nvim",
        event = { "VeryLazy" },
        keys = {
            { "<Leader>.", function() require('dropbar.api').pick() end, desc = "Pick symbol" },
            { "<M-.>", function() require('dropbar.api').pick() end, desc = "Pick symbol" },
        },
        opts = {
            menu = {
                keymaps = {
                    ["<Esc>"] = function()
                        local menu = require("dropbar.api").get_current_dropbar_menu()
                        if menu then
                            menu:close(true)
                        end
                    end,
                },
            },
        },
        config = true,
    },

    -- Annotation generator
    {
        "danymat/neogen",
        keys = {
             { "<Leader>C", function() require("neogen").generate({}) end, desc = "Neogen Comment" }
        },
        opts = {
            snippet_engine = "luasnip",
            languages = {
                python = {
                    template = {
                        annotation_convention = "reST",
                    },
                },
            },
        },
    },

}
