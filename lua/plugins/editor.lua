return {

    -- Which key is that? Which-key!
    {
        "folke/which-key.nvim",
        opts = {
            plugins = { spelling = false },
            defaults = {
                b = { name = "Buffer" },
                f = { name = "Find (Telescope)" },
                g = { name = "Git (Telescope)" },
                h = { name = "Git hunks" },
                l = { name = "LSP" },
                t = { name = "Toggle" },
                T = { name = "Terminal" },
                x = { name = "Diagnostics" },
                c = { name = "CMake" },
                cs = { name = "Select" },
                csp = { name = "Preset" },
                d = { name = "+debug" },
                da = { name = "+adapters" },
                ["|"] = { name = "Table" },
            },
        },
        event = "VeryLazy",
        config = function(_, opts)
            local wk = require("which-key")
            wk.setup(opts)
            wk.register(opts.defaults, { prefix = "<Leader>" })
        end,
    },

    -- Search/replace in multiple files
    {
        "nvim-pack/nvim-spectre",
        keys = {
            { "<leader>sr", function() require("spectre").open() end, desc = "Replace in files (Spectre)" },
        },
    },

    -- Smarter Splits
    {
        "mrjones2014/smart-splits.nvim",
        keys = {
            -- Move between splits
            { "<S-Left>",  function() require("smart-splits").move_cursor_left() end, desc = "Move to left split", mode = {"n", "i", "t"} },
            { "<S-Down>",  function() require("smart-splits").move_cursor_down() end, desc = "Move to below split", mode = {"n", "i", "t"} },
            { "<S-Up>",    function() require("smart-splits").move_cursor_up() end, desc = "Move to above split", mode = {"n", "i", "t"} },
            { "<S-Right>", function() require("smart-splits").move_cursor_right() end, desc = "Move to right split", mode = {"n", "i", "t"} },

            -- Resize with arrows
            { "<C-S-Left>",  function() require("smart-splits").resize_left() end, desc = "Resize split left", mode = {"n", "i", "t"} },
            { "<C-S-Down>",  function() require("smart-splits").resize_down() end, desc = "Resize split down", mode = {"n", "i", "t"} },
            { "<C-S-Up>",    function() require("smart-splits").resize_up() end, desc = "Resize split up", mode = {"n", "i", "t"} },
            { "<C-S-Right>", function() require("smart-splits").resize_right() end, desc = "Resize split right", mode = {"n", "i", "t"} },
        },
        opts = {
            ignored_filetypes = {
                "nofile",
                "quickfix",
                "qf",
                "prompt",
            },
            ignored_buftypes = { "nofile", "prompt" },
        },
    },

    -- Illuminate - Highlight usages of symbol under cursor
    {
        "RRethy/vim-illuminate",
        -- event = { "CursorHold", "CursorHoldI" },
        cmds = {
            "illuminateToggle", "IlluminatePause", "IlluminateResume"
        },
        keys = {
            { "<Leader>ti", "<Cmd>IlluminateToggle<CR", desc = "Toggle Illuminate (highlight symbols)" },
            {
                "<a-n>",
                function() require("illuminate").next_reference({ wrap = true }) end,
                desc = "Next illuminated ref",
                noremap = true
            },
            {
                "<a-p>",
                function() require("illuminate").next_reference({ reverse = true, wrap = true }) end,
                desc = "Previous illuminated ref",
                noremap = true
            },
        },
        opts = {
            providers = {
                "lsp",
                "treesitter",
                "regex",
            },
            delay = 200,
            filetypes_denylist = {
                "alpha",
                "dashboard",
                "DiffviewFiles",
                "dirvish",
                "DoomInfo",
                "DressingSelect",
                "dropbar_menu",
                "fugitive",
                "help",
                "lazy",
                "lsgsagaoutline",
                "markdown",
                "neogitstatus",
                "neo-tree",
                "norg",
                "NvimTree",
                "Outline",
                "spectre_panel",
                "TelescopePrompt",
                "text",
                "toggleterm",
                "Trouble",
            },
            under_cursor = true,
            min_count_to_highlight = 2,
            large_file_cutoff = 3000,
        },
        config = function(_, opts)
            require("illuminate").configure(opts)
        end,
    },

    -- Indent guides for Neovim
    {
        "lukas-reineke/indent-blankline.nvim",
        event = { "BufReadPost", "BufNewFile" },
        cmd = { "IndentBlanklineEnable", "IndentBlanklineDisable" },
        opts = {
            char = "▏",
            show_end_of_line = false,
            show_first_indent_level = false,
            show_trailing_blankline_indent = false,
            show_current_context = false,
            buftype_exclude = {
                "DiffviewFilePanel",
                "loclist",
                "nofile",
                "prompt",
                "quickfix",
                "terminal",
            },
            filetype_exclude = {
                "alpha",
                "checkhealth",
                "dashboard",
                "dropbar_menu",
                "git",
                "gitconfig",
                "help",
                "lazy",
                "lspinfo",
                "man",
                "markdown",
                "mason",
                "neo-tree",
                "packer",
                "snippets",
                "terminal",
                "text",
                "TelescopePrompt",
                "TelescopeResults",
                "Trouble",
            },
        },
        init = function(self)
            -- Disable indent lines in insert mode and in diff view
            local gid = vim.api.nvim_create_augroup("indent_blankline", { clear = true })
            vim.api.nvim_create_autocmd("InsertEnter", {
                pattern = "*",
                group = gid,
                callback = function()
                    if vim.fn.exists(":IndentBlanklineDisable") > 0 then
                        vim.cmd("IndentBlanklineDisable")
                    end
                end,
            })

            vim.api.nvim_create_autocmd("InsertLeave", {
                pattern = "*",
                group = gid,
                callback = function()
                    local deny = vim.tbl_contains(self.opts.filetype_exclude, vim.bo.filetype) or
                                 vim.wo.diff or vim.b.large_buf
                    if not deny and vim.fn.exists(":IndentBlanklineEnable") > 0 then
                        vim.cmd("IndentBlanklineEnable")
                    end
                end,
            })

            vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
                pattern = "*",
                group = gid,
                callback = function()
                    if vim.fn.exists(":IndentBlanklineEnable") > 0 and vim.wo.diff then
                        vim.cmd([[IndentBlanklineDisable]])
                    end
                end,
            })
        end,
    },

    -- Smooth escaping
    {
        "max397574/better-escape.nvim",
        opts = {
            mapping = {"ii", "uu"},
        },
    },

    -- Undo tree
    {
        "mbbill/undotree",
        cmd = { "UndotreeToggle" },
        keys = {
            { "<S-F4>", "<Cmd>UndotreeToggle<CR>", desc = "Toggle Undo tree", mode = {"n", "i"} },
            { "<F16>", "<Cmd>UndotreeToggle<CR>", desc = "Toggle Undo tree", mode = {"n", "i"} },
        },
    },

    -- motion plugin
    {
        "phaazon/hop.nvim",
        branch = "v2",
        keys = {
            { "é", "<Cmd>HopWord<CR>", desc = "Hop to word", mode = { "n", "x", "o" } },
            { "è", "<Cmd>HopWordMW<CR>", desc = "Hop to word Multi-Window", mode = { "n", "x", "o" } },
            { "t", "<Cmd>HopLineStart<CR>", desc = "Hop to line", mode = { "n", "x", "o" } },
            { "T", "<Cmd>HopLineStartMW<CR>", desc = "Hop to line Multi-Window", mode = { "n", "x", "o" } },
            { "f", "<Cmd>HopChar1CurrentLineAC<CR>", desc = "Hop to char after cursor", mode = { "n", "x", "o" } },
            { "F", "<Cmd>HopChar1CurrentLineBC<CR>", desc = "Hop to char before cursor", mode = { "n", "x", "o" } },
        },
        opts = {
            keys = "ecitusarnmovpdélbjkqxgyhàf",
        },
    },

    -- A pretty diagnostics, references, telescope results, quickfix and location list
    {
        "folke/trouble.nvim",
        cmd = { "TroubleToggle", "Trouble" },
        opts = { use_diagnostics_signs = true },
        keys = {
            { "<leader>xx", "<Cmd>TroubleToggle<CR>", desc = "Toggle the list of diagnostics" },
            { "<leader>xw", "<Cmd>TroubleToggle workspace_diagnostics<CR>", desc = "Toggle the list of diagnostics for this workspace" },
            { "<leader>xd", "<Cmd>TroubleToggle document_diagnostics<CR>", desc = "Toggle the list of diagnostics for this document" },
            { "<leader>xl", "<Cmd>TroubleToggle loclist<CR>", desc = "Toggle the location list" },
            { "<leader>xq", "<Cmd>TroubleToggle quickfix<CR>", desc = "Toggle the quickfix list" },
            { "<leader>xr", "<Cmd>TroubleToggle lsp_references<CR>", desc = "Toggle the list of LSP References" },
            { "gR", "<Cmd>TroubleToggle lsp_references<CR>", desc = "Toggle the list of LSP References" },
            {
                "[q",
                function()
                    if require("trouble").is_open() then
                        require("trouble").previous({ skip_groups = true, jump = true })
                    else
                        vim.cmd.cprev()
                    end
                end,
                desc = "Previous trouble/quickfix item",
            },
            {
                "]q",
                function()
                    if require("trouble").is_open() then
                        require("trouble").next({ skip_groups = true, jump = true })
                    else
                        vim.cmd.cnext()
                    end
                end,
                desc = "Next trouble/quickfix item",
            },
        },
    },

    -- Highlight, list and search todo comments in your projects
    {
        "folke/todo-comments.nvim",
        cmd = { "TodoTrouble", "TodoTelescope" },
        event = { "BufReadPost", "BufNewFile" },
        keys = {
            { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
            { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
            { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
        },
        opts = {
            keywords = {
                FIX = { alt = { "TOFIX", "FIXME", "BUG", "FIXIT", "ISSUE" } },
            },
        },
    },

    -- Split / join trees
    {
        "Wansmer/treesj",
        keys = {
            {
                "<leader>J",
                function()
                    require('treesj').toggle({ split = { recursive = true } })
                end,
                desc = "Toggle split or join block"
            },
        },
        opts = { use_default_keymaps = false },
    },

    -- Align stuff
    {
        "godlygeek/tabular",
        cmd = "Tabularize",
        keys = {
            { "<A-a>=", "<Cmd>Tabularize /=<CR>", desc = "Align on =", mode = {"n", "v"} },
            { "<A-a>,", "<Cmd>Tabularize /,<CR>", desc = "Align on ,", mode = {"n", "v"} },
            { "<A-a><Bar>", "<Cmd>Tabularize /<Bar><CR>", desc = "Align on |", mode = {"n", "v"} },
        },
    },

    -- Binary editor
    {
        "shougo/vinarise.vim",
        cmd = "Vinarise",
    },

    -- Highlight colours
    {
        "NvChad/nvim-colorizer.lua",
        cmd = "ColorizerToggle",
        opts = {
            filetypes = { "*", "!lazy" },
            buftype = { "*", "!prompt", "!nofile" },
            user_default_options = {
                RGB = true,
                RRGGBB = true,
                names = false,
                RRGGBBAA = true,
                AARRGGBB = false,
                rgb_fn = true,
                hsl_fn = true,
                css = false,
                css_fn = true,
                mode = "background",
                virtualtext = "",
            },
        },
    },

    -- Highlight words with different colors
    {
        "Mr-LLLLL/interestingwords.nvim",
        keys = {
            { "<Leader>k", desc = "Color word" },
            { "<Leader>K", desc = "Cancel color word" },
        },
        opts = {
            colors = {
                "#fce94f",
                "#fcaf3e",
                "#e9b96e",
                "#8ae234",
                "#729fcf",
                "#ad7fa8",
                "#ef2929",
                "#eeeeec",
                "#888a85",
                "#c4a000",
                "#ce5c00",
                "#8f5902",
                "#4e9a06",
                "#204a87",
                "#5c3566",
                "#a40000",
                "#babdb6",
                "#2e3436",
            },
            search_key = nil,
            cancel_search_key = nil,
        },
        config = true,
    },

    -- Surround stuff
    {
        "echasnovski/mini.surround",
        version = false,
        event = "VeryLazy",
        config = true,
    },

    -- Bionic Reading
    {
        "nullchilly/fsread.nvim",
        cmd = { "FSRead", "FSClear", "FSToggle" },
        config = function()
            vim.g.flow_strengh = 0.5
            vim.api.nvim_set_hl(0, "FSPrefix", { fg = "#d8d0A3", bold = true })
            vim.api.nvim_set_hl(0, "FSSuffix", { fg = "#A2A199", bold = false })
        end,
    },

    -- UFO Better folding
    {
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
        event = { "BufReadPost", "BufNew" },
        opts = {},
        init = function()
            vim.keymap.set("n", "zR", function()
                require("ufo").openAllFolds()
            end)
            vim.keymap.set("n", "zM", function()
                require("ufo").closeAllFolds()
            end)
        end,
    },

    -- Repeat commands
    { "tpope/vim-repeat" },

}
