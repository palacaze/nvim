return {

    -- mason automatic lsp, debuggers & other tools installation
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        cmd = { "Mason", "MasonUpdate", "MasonInstall", "MasonUninstall" },
        opts = {
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗"
                }
            },
            ensure_installed = {
                "bash-langage-server",
                "codelldb",
                "commitlint",
                "json-lsp",
                "ltex-ls",
                "markdownlint",
                "marksman",
                "ruff",
                "basedpyright",
                "debugpy",
            },
            PATH = "append",
        },
    },

    -- make tables
    {
        "dhruvasagar/vim-table-mode",
        enabled = false,
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
            -- BUG: disable popup, as the dropbar triggers the E36 "No room" bug,
            -- https://github.com/neovim/neovim/issues/19464
            vim.g.matchup_matchparen_offscreen = {}  -- { method = "popup" }
            vim.g.matchup_surround_enabled = 0
            vim.g.matchup_matchparen_deferred = 1
            vim.g.matchup_matchparen_deferred_show_delay = 200
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

            local with_cmp, cmp = pcall(require, "cmp")
            if with_cmp then
                local cmp_autopairs = require("nvim-autopairs.completion.cmp")
                cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
            end
        end,
    },

    -- Smart and powerful comment plugin for neovim
    {
        "numToStr/Comment.nvim",
        dependencies = {
            { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true },
        },
        keys = {
            { "gcc", desc = "Toggle comment (linewise)" },
            { "gbc", desc = "Toggle comment (blockwise)" },
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
                    local u = require("utils")
                    vim.api.nvim_feedkeys(u.esc, "nx", false)
                    require("Comment.api").toggle.linewise(vim.fn.visualmode())
                end,
                desc = "Toggle comment (linewise)",
                mode = "v",
            },
            {
                "<M-y>",
                function()
                    local u = require("utils")
                    vim.api.nvim_feedkeys(u.esc, "nx", false)
                    require("Comment.api").toggle.blockwise(vim.fn.visualmode())
                end,
                desc = "Toggle comment (blockwise)",
                mode = "v",
            },
        },
        config = function()
            require("Comment").setup({
                pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
            })
        end,
    },

    -- Code outline window
    {
        "stevearc/aerial.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        cmds = { "AerialToggle" },
        keys = {
            { "<Leader>a", "<Cmd>AerialToggle!<CR>", desc = "Toggle Aerial outline window" },
            { "<Leader>n", "<Cmd>AerialNavToggle<CR>", desc = "Toggle Aerial navigation window" },
        },
        opts = {
            backends = { "lsp", "treesitter", "markdown", "asciidoc", "man" },
            nav = {
                preview = true,
                keymaps = {
                    ["<CR>"] = "actions.jump",
                    ["<2-LeftMouse>"] = "actions.jump",
                    ["<C-v>"] = "actions.jump_vsplit",
                    ["<C-s>"] = "actions.jump_split",
                    ["<left>"] = "actions.left",
                    ["<right>"] = "actions.right",
                    ["<esc>"] = "actions.close",
                },
            },
        },
    },

    -- A breadcrumb bar showing symbols
    {
        "Bekaboo/dropbar.nvim",
        enabled = false,
        cond = vim.fn.has("nvim-0.10") > 0,
        event = { "VeryLazy" },
        keys = {
            { "<Leader>.", function() require('dropbar.api').pick() end, desc = "Pick symbol" },
            { "<M-.>", function() require('dropbar.api').pick() end, desc = "Pick symbol" },
        },
        opts = {
            bar = {
                sources = function(_, _)
                    local sources = require('dropbar.sources')
                    return {
                        sources.path,
                        {
                            get_symbols = function(buf, win, cursor)
                                if vim.bo[buf].ft == 'markdown' then
                                    return sources.markdown.get_symbols(buf, win, cursor)
                                end
                                local is_cpp = vim.bo[buf].ft == "cpp"
                                for _, source in ipairs({ sources.lsp, sources.treesitter }) do
                                    local symbols = source.get_symbols(buf, win, cursor)
                                    if not vim.tbl_isempty(symbols) then
                                        if is_cpp then
                                            for _, sym in ipairs(symbols) do
                                                if sym.name == "(anonymous namespace)" then
                                                    sym.name = "󰊠 "
                                                end
                                            end
                                        end
                                        return symbols
                                    end
                                end
                                return {}
                            end,
                        },
                    }
                end
            },
            general = {
                update_interval = 100,
                enable = function(buf, win)
                    local name = vim.api.nvim_buf_get_name(buf)
                    local filetype = vim.bo[buf].filetype
                    return not vim.api.nvim_win_get_config(win).zindex
                        and vim.bo[buf].buftype == ""
                        and name ~= ""
                        and name:find("diffview://", 1, true) ~= 1
                        and not vim.wo[win].diff
                end,
            },
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
                        annotation_convention = "google_docstrings",
                    },
                },
            },
        },
    },

}
