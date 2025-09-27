return {

    -- mason automatic lsp, debuggers & other tools installation
    {
        "mason-org/mason.nvim",
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
