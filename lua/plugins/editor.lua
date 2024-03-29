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
                d = { name = "Debug" },
                da = { name = "Adapters" },
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
        cmd = "Spectre",
        keys = {
            { "<leader>sr", function() require("spectre").open() end, desc = "Replace in files (Spectre)" },
        },
        opts = { open_cmd = "noswapfile vnew" },
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
        cmd = {
            "IlluminateToggle", "IlluminatePause", "IlluminateResume"
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
        main = "ibl",
        event = { "BufReadPost", "BufNewFile" },
        cmd = { "IBLEnable", "IBLDisable" },
        opts = {
            indent = {
                char = "┆",
                tab_char = "┆",
                smart_indent_cap = true,
            },
            scope = { enabled = false },
            exclude = {
                buftypes = {
                    "DiffviewFilePanel",
                    "loclist",
                    "nofile",
                    "prompt",
                    "quickfix",
                    "terminal",
                },
                filetypes = {
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
        },
        config = function(_, opts)
            require("ibl").setup(opts)
            local hooks = require("ibl.hooks")
            hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
            hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_tab_indent_level)
            -- show_end_of_line = false,
        end,
        init = function(self)
            -- Disable indent lines in insert mode and in diff view
            local gid = vim.api.nvim_create_augroup("indent_blankline", { clear = true })
            vim.api.nvim_create_autocmd("InsertEnter", {
                pattern = "*",
                group = gid,
                callback = function()
                    if vim.fn.exists(":IBLDisable") > 0 then
                        vim.cmd("IBLDisable")
                    end
                end,
            })

            vim.api.nvim_create_autocmd("InsertLeave", {
                pattern = "*",
                group = gid,
                callback = function()
                    local deny = vim.tbl_contains(self.opts.exclude.filetypes, vim.bo.filetype) or
                                 vim.wo.diff or vim.b.large_buf
                    if not deny and vim.fn.exists(":IBLEnable") > 0 then
                        vim.cmd("IBLEnable")
                    end
                end,
            })

            vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
                pattern = "*",
                group = gid,
                callback = function()
                    if vim.fn.exists(":IBLEnable") > 0 and vim.wo.diff then
                        vim.cmd([[IBLDisable]])
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
            { "<M-A>=", "<Cmd>Tabularize /=<CR>", desc = "Align on =", mode = {"n", "v"} },
            { "<M-A>,", "<Cmd>Tabularize /,<CR>", desc = "Align on ,", mode = {"n", "v"} },
            { "<M-A><Bar>", "<Cmd>Tabularize /<Bar><CR>", desc = "Align on |", mode = {"n", "v"} },
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

    -- Highlight words and expressions
    {
        "azabiong/vim-highlighter",
        init = function()
            vim.g.HiSet   = 'é<CR>'
            vim.g.HiErase = 'é<BS>'
            vim.g.HiClear = 'é<C-L>'
            vim.g.HiFind  = 'é<Tab>'
            vim.g.HiSetSL = 'è<CR>'
        end,
    },

    -- Highlight words with different colors
    {
        "Mr-LLLLL/interestingwords.nvim",
        enabled = false,
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
        enabled = false,
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
        opts = {
            open_fold_hl_timeout = 150,
            preview = {
                win_config = {
                    border = "none",
                    winhighlight = "Normal:Folded",
                    winblend = 0
                },
                mappings = {
                    scrollU = "<C-u>",
                    scrollD = "<C-d>",
                    jumpTop = "[",
                    jumpBot = "]"
                }
            },
        },
        keys = {
            { "z1", function() require("ufo").closeFoldsWith(0) end, desc = "Unfold 1 level" },
            { "z2", function() require("ufo").closeFoldsWith(1) end, desc = "Unfold 2 levels" },
            { "z3", function() require("ufo").closeFoldsWith(2) end, desc = "Unfold 3 levels" },
            { "z4", function() require("ufo").closeFoldsWith(3) end, desc = "Unfold 4 levels" },
            { "z5", function() require("ufo").closeFoldsWith(4) end, desc = "Unfold 5 levels" },
            { "z6", function() require("ufo").closeFoldsWith(5) end, desc = "Unfold 6 levels" },
            { "z0", function() require("ufo").closeFoldsWith(99) end, desc = "Unfold all" },
            { "à", "za", desc = "Toggle fold", remap = true, silent = true, nowait = true },
        },
        init = function()
            vim.keymap.set("n", "zR", function()
                require("ufo").openAllFolds()
            end)
            vim.keymap.set("n", "zM", function()
                require("ufo").closeAllFolds()
            end)
            vim.keymap.set("n", "Z", function()
                local winid = require("ufo").peekFoldedLinesUnderCursor()
                -- inside the preview window
                if winid then
                    -- local bufnr = vim.api.nvim_win_get_buf(winid)
                    vim.wo[winid].list = false
                else
                    vim.lsp.buf.hover()
                end
            end)
        end,
    },

    -- Repeat commands
    { "tpope/vim-repeat" },

}
