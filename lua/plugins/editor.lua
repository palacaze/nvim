return {

    -- Nicer search
    {
        "kevinhwang91/nvim-hlslens",
        lazy = true,
        keys = {
            { "n", [[<Cmd>execute("normal! " . v:count1 . "n")<CR><Cmd>lua require("hlslens").start()<CR>]], desc = "Next match" },
            { "N", [[<Cmd>execute("normal! " . v:count1 . "N")<CR><Cmd>lua require("hlslens").start()<CR>]], desc = "Previous match" },
            { "*", [[*<Cmd>lua require("hlslens").start()<CR>]], desc = "Search forward" },
            { "#", [[#<Cmd>lua require("hlslens").start()<CR>]], desc = "Search backward" },
            { "g*", [[g*<Cmd>lua require("hlslens").start()<CR>]], desc = "Like *, but also incomplete match" },
            { "g#", [[g#<Cmd>lua require("hlslens").start()<CR>]], desc = "Like #, but also incomplete match" },
        },
        main = "hlslens",
        config = function()
            require("scrollbar.handlers.search").setup({})
        end,
    },

    -- Find, Filter, Preview, Pick. All lua, all the time
    {
        "nvim-telescope/telescope.nvim",
        version = false,
        dependencies = {
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
            },
            "nvim-telescope/telescope-file-browser.nvim",
            "nvim-telescope/telescope-symbols.nvim",
        },
        cmd = "Telescope",
        keys = {
            { "<F6>", "<Cmd>Telescope find_files<CR>", desc = "Find files", mode = {"n", "i"} },
            { "<S-F6>" },  -- file browser
            { "<F7>", "<Cmd>Telescope live_grep<CR>", desc = "Search in files", mode = {"n", "i"} },
            { "<S-F7>" },  -- file browser
            { "<Leader>fF", "<Cmd>Telescope find_files<CR>", desc = "Find files" },
            { "<Leader>fg", "<Cmd>Telescope live_grep<CR>", desc = "Search in files" },
            { "<Leader>fo", "<Cmd>Telescope oldfiles<CR>", desc = "Find in history" },
            { "<Leader>fh", "<Cmd>Telescope help_tags<CR>", desc = "Find help" },
            { "<Leader>fs", "<Cmd>Telescope symbols<CR>", desc = "Find symbols" },
            { "<Leader>gc", "<Cmd>Telescope git_commits<CR>", desc = "Find git commits" },
            { "<Leader>gb", "<Cmd>Telescope git_branches<CR>", desc = "Find git branches" },
            { "<Leader>gs", "<Cmd>Telescope git_status<CR>", desc = "Find git status" },
            {
                "<Leader>fm",
                function()
                    require("telescope.builtin").man_pages({ sections = { "ALL" } })
                end,
                desc = "Find man pages"
            },
            {
                "<Leader>fv",
                function()
                    require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
                end,
                desc = "Find files in vim config"
            },
            {
                "<Leader>fS",
                function()
                    require("telescope.builtin").find_files({ cwd = "~/travail/SURFO/indu" })
                end,
                desc = "Find files in SURFO"
            },
            {
                "z=",
                function()
                    local word = vim.fn.expand("<cword>")
                    local theme = require("telescope.themes").get_cursor({
                        prompt_title = "Spell suggestions for " .. word
                    })
                    require("telescope.builtin").spell_suggest(theme)
                end,
                desc = "Spell suggestions",
            },
        },
        opts = {
            defaults = {
                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                    "--trim",
                },
                prompt_prefix = " 🔍  ",
                initial_mode = "insert",
                selection_strategy = "reset",
                sorting_strategy = "ascending",
                layout_strategy = "horizontal",
                layout_config = {
                    horizontal = {
                        prompt_position = "top",
                        -- preview_width = 0.5,
                        -- results_width = 0.5,
                    },
                    vertical = {
                        mirror = false,
                    },
                    width = 0.9,
                    height = 0.9,
                },
                winblend = 20,
                border = {},
                borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
                color_devicons = true,
                mappings = {
                    n = {
                        ["q"] = function(...) require("telescope.actions").close(...) end,
                        ["<C-Up>"] = function(...) require("telescope.actions").preview_scrolling_up(...) end,
                        ["<C-Down>"] = function(...) require("telescope.actions").preview_scrolling_down(...) end,
                    },
                    i = {
                        ["<c-t>"] = function(...)
                            return require("trouble.providers.telescope").open_with_trouble(...)
                        end,
                        ["<a-t>"] = function(...)
                            return require("trouble.providers.telescope").open_selected_with_trouble(...)
                        end,
                        ["<esc>"] = function(...) require("telescope.actions").close(...) end,
                        ["<C-Up>"] = function(...) require("telescope.actions").preview_scrolling_up(...) end,
                        ["<C-Down>"] = function(...) require("telescope.actions").preview_scrolling_down(...) end,
                    },
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
                fzy_native = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
                file_browser = {
                    hijack_netrw = true,
                },
            },
        },
        config = function(_, opts)
            require("telescope").setup(opts)
            require("telescope").load_extension("fzf")
            local fb = require("telescope").load_extension("file_browser")
            local u = require("config.utils")
            u.map_ni("<S-F6>", function() fb.file_browser({ grouped = true }) end, "Browse Files")
            u.map_n("<Leader>fb", function() fb.file_browser({ grouped = true }) end, "Browse Files")
        end,
    },

    -- Which key is that? Which-key!
    {
        "folke/which-key.nvim",
        opts = {
            plugins = { spelling = true },
            defaults = {
                mode = { "n", "v" },
                ["b"] = { name = "Buffer" },
                ["f"] = { name = "Find (Telescope)" },
                ["g"] = { name = "Git (Telescope)" },
                ["h"] = { name = "Git hunks" },
                ["l"] = { name = "LSP" },
                ["t"] = { name = "Toggle" },
                ["T"] = { name = "Terminal" },
                ["x"] = { name = "Diagnostics" },
            },
        },
        event = "VeryLazy",
        config = function(_, opts)
            local wk = require("which-key")
            wk.setup(opts)
            wk.register(opts.defaults)
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

    {
        "RRethy/vim-illuminate",
        event = { "CursorHold", "CursorHoldI" },
        keys = {
            {
                "<a-n>",
                function() require("illuminate").next_reference({ wrap = true }) end,
                noremap = true
            },
            {
                "<a-p>",
                function() require("illuminate").next_reference({ reverse = true, wrap = true }) end,
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
                "dirvish",
                "DoomInfo",
                "DressingSelect",
                "fugitive",
                "help",
                "lsgsagaoutline",
                "neogitstatus",
                "norg",
                "NvimTree",
                "Outline",
                "spectre_panel",
                "TelescopePrompt",
                "toggleterm",
                "Trouble",
            },
            under_cursor = true,
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
            show_current_context = true,
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
                    if not vim.tbl_contains(self.opts.filetype_exclude, vim.bo.filetype) and not vim.wo.diff then
                        if vim.fn.exists(":IndentBlanklineEnable") > 0 then
                            vim.cmd("IndentBlanklineEnable")
                        end
                    end
                end,
            })

            vim.api.nvim_create_autocmd("BufRead", {
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
        },
    },

    -- motion plugin
    {
        "phaazon/hop.nvim",
        branch = "v2",
        keys = {
            { "f", function() require("hop").hint_char1() end, desc = "Hop 1 char", mode = { "n", "x", "o" } },
            { "F", function() require("hop").hint_char2() end, desc = "Hop 2 chars", mode = { "n", "x", "o" } },
            { "t", function() require("hop").hint_lines_skip_whitespace() end, desc = "Hop to line", mode = { "n", "x", "o" } },
            { "T", function() require("hop").hint_words() end, desc = "Hop to word", mode = { "n", "x", "o" } },
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
        config = true,
    },

    -- Split / join trees
    {
        "Wansmer/treesj",
        keys = {
            {
                "<leader>M",
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
                mode = "virtualtext",
                virtualtext = "",
            },
        },
    },

    -- Repeat commands
    { "tpope/vim-repeat" },

}
