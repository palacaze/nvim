-- The following two functions are taken form LazyVim
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/init.lua

-- Returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@return string
local function get_project_root()
    ---@type string?
    local path = vim.api.nvim_buf_get_name(0)
    path = path ~= "" and vim.loop.fs_realpath(path) or nil
    ---@type string[]
    local roots = {}
    if path then
        for _, client in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
            local workspace = client.config.workspace_folders
            local paths = workspace
                and vim.tbl_map(function(ws)
                    return vim.uri_to_fname(ws.uri)
                end, workspace)
                or client.config.root_dir and { client.config.root_dir }
                or {}
            for _, p in ipairs(paths) do
                local r = vim.loop.fs_realpath(p)
                if path:find(r, 1, true) then
                    roots[#roots + 1] = r
                end
            end
        end
    end
    table.sort(roots, function(a, b)
        return #a > #b
    end)
    ---@type string?
    local root = roots[1]
    if not root then
        path = path and vim.fs.dirname(path) or vim.loop.cwd()
        ---@type string?
        root = vim.fs.find({ ".git", ".clang-format" }, { path = path, upward = true })[1]
        root = root and vim.fs.dirname(root) or vim.loop.cwd()
    end
    ---@cast root string
    return root
end


-- Returns a function that calls telescope.
-- cwd defaults to project root, if any. the "files" builtin chooses between
-- git_files if we are in a git repo and find_fifes otherwise.
local function telescope(builtin, opts)
    local params = { builtin = builtin, opts = opts }
    return function()
        builtin = params.builtin
        opts = params.opts
        opts = vim.tbl_deep_extend("force", { cwd = get_project_root() }, opts or {})
        if builtin == "files" then
            if vim.loop.fs_stat((opts.cwd or vim.loop.cwd()) .. "/.git") then
                opts.show_untracked = true
                builtin = "git_files"
            else
                builtin = "find_files"
            end
        end
        require("telescope.builtin")[builtin](opts)
    end
end

-- Returns a function that calls fzf-lua.
-- cwd defaults to project root, if any. the "files" builtin chooses between
-- git_files if we are in a git repo and find_fifes otherwise.
local function fzflua(builtin, opts)
    local params = { builtin = builtin, opts = opts }
    return function()
        builtin = params.builtin
        opts = params.opts
        opts = vim.tbl_deep_extend("force", { cwd = get_project_root() }, opts or {})
        if builtin == "files" then
            if vim.loop.fs_stat((opts.cwd or vim.loop.cwd()) .. "/.git") then
                opts.show_untracked = true
                builtin = "git_files"
            else
                builtin = "files"
            end
        end
        require("fzf-lua")[builtin](opts)
    end
end

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
        enabled = false,
        version = false,
        dependencies = {
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
            },
            "nvim-telescope/telescope-file-browser.nvim",
            "nvim-telescope/telescope-symbols.nvim",
        },
        cmd = "Telescope",
        keys = {
            { "<Leader>,", "<Cmd>Telescope buffers show_all_buffers=true<CR>", desc = "Switch Buffer" },
            { "<Leader>/", telescope("live_grep"), desc = "Grep (root dir)" },
            { "<Leader>:", "<Cmd>Telescope command_history<CR>", desc = "Command History" },
            { "<Leader><Space>", telescope("files"), desc = "Find files (root dir)" },

            { "<S-F6>", "<Cmd>Telescope file_browser<CR>", desc = "Browse Files (cwd)" },
            { "<F18>", "<Cmd>Telescope file_browser<CR>", desc = "Browse Files (cwd)" },
            { "<Leader>fb", "<Cmd>Telescope file_browser<CR>", desc = "Browse Files (cwd)" },
            { "<Leader>fB", "<Cmd>Telescope file_browser path=%:p:h<CR>", desc = "Browse Files (file dir)" },
            { "<F6>", telescope("files"), desc = "Find files (root dir)", mode = {"n", "i"} },
            { "<Leader>ff", telescope("files"), desc = "Find files (root dir)" },
            { "<Leader>fF", telescope("files", { cwd = false }), desc = "Find files (cmd)" },
            { "<F7>", telescope("live_grep"), desc = "Grep (root dir)", mode = {"n", "i"} },
            { "<Leader>fg", telescope("live_grep"), desc = "Grep (root dir)" },
            { "<Leader>fG", telescope("live_grep", { cwd = vim.loop.cwd() }), desc = "Grep (cwd)" },
            { "<Leader>fr", telescope("oldfiles"), desc = "Recent files (root dir)" },
            { "<Leader>fR", telescope("oldfiles", { cwd = vim.loop.cwd() }), desc = "Recent files (cwd)" },

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
                file_ignore_patterns = { "^cmake/vcpkg/" },
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
                    grouped = true,
                    hijack_netrw = true,
                },
            },
        },
        config = function(_, opts)
            require("telescope").setup(opts)
            require("telescope").load_extension("fzf")
            require("telescope").load_extension("file_browser")
        end,
    },

    {
        "ibhagwan/fzf-lua",
        requires = { 'nvim-tree/nvim-web-devicons' },
        cmd = { "FzfLua" },
        keys = {
            { "<Leader>,", "<Cmd>FzfLua buffers<CR>", desc = "Switch Buffer" },
            { "<Leader>/", fzflua("live_grep"), desc = "Grep (root dir)" },
            { "<Leader>:", "<Cmd>FzfLua command_history<CR>", desc = "Command History" },
            { "<Leader><Space>", fzflua("files"), desc = "Find files (root dir)" },

            { "<F6>", fzflua("files"), desc = "Find files (root dir)", mode = {"n", "i"} },
            { "<Leader>ff", fzflua("files"), desc = "Find files (root dir)" },
            { "<Leader>fF", fzflua("files", { cwd = false }), desc = "Find files (cmd)" },
            { "<F7>", fzflua("live_grep"), desc = "Grep (root dir)", mode = {"n", "i"} },
            { "<Leader>fg", fzflua("live_grep"), desc = "Grep (root dir)" },
            { "<Leader>fG", fzflua("live_grep", { cwd = vim.loop.cwd() }), desc = "Grep (cwd)" },
            { "<Leader>fr", fzflua("oldfiles"), desc = "Recent files (root dir)" },
            { "<Leader>fR", fzflua("oldfiles", { cwd = vim.loop.cwd() }), desc = "Recent files (cwd)" },

            { "<Leader>fh", "<Cmd>FzfLua help_tags<CR>", desc = "Find help" },
            { "<Leader>gc", "<Cmd>FzfLua git_commits<CR>", desc = "Find git commits" },
            { "<Leader>gb", "<Cmd>FzfLua git_branches<CR>", desc = "Find git branches" },
            { "<Leader>gs", "<Cmd>FzfLua git_status<CR>", desc = "Find git status" },
            { "<Leader>fm", "<Cmd>FzfLua man_pages<CR>", desc = "Find man pages" },
            {
                "<Leader>fv",
                function()
                    require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
                end,
                desc = "Find files in vim config"
            },
            {
                "<Leader>fS",
                function()
                    require("fzf-lua").files({ cwd = "~/travail/SURFO/indu" })
                end,
                desc = "Find files in SURFO"
            },
            {
                "z=",
                function()
                    local word = vim.fn.expand("<cword>")
                    local position = vim.api.nvim_win_get_position(0)
                    local line = vim.fn.winline() + position[1]
                    local col = vim.fn.wincol() + position[2]
                    local prompt = "Spell suggestions for " .. word .. ": "
                    require("fzf-lua").spell_suggest({
                        prompt = prompt,
                        winopts = { width = 0.5, height = 0.2, row = line, col = col }
                    })
                end,
                desc = "Spell suggestions",
            },
        },
        opts = {
            winopts = {
                width   = 0.9,
                height  = 0.9,
                preview = { layout = "flex" },
            },
            fzf_opts = {
                ["--layout"] = "reverse",
                ["--marker"] = "+",
            },
            keymap = {
                builtin = {
                    ["<F1>"] = "toggle-help",
                    ["<F2>"] = "toggle-fullscreen",
                    ["<F3>"] = "toggle-preview-wrap",
                    ["<F4>"] = "toggle-preview",
                    ["<F5>"] = "toggle-preview-ccw",
                    ["<F6>"] = "toggle-preview-cw",
                    ["<C-d>"] = "preview-page-down",
                    ["<C-u>"] = "preview-page-up",
                    ["<C-down>"] = "preview-page-down",
                    ["<C-up>"] = "preview-page-up",
                },
                fzf = {
                    ["ctrl-z"] = "abort",
                    ["ctrl-f"] = "half-page-down",
                    ["ctrl-b"] = "half-page-up",
                    ["ctrl-a"] = "beginning-of-line",
                    ["ctrl-e"] = "end-of-line",
                    ["alt-a"]  = "toggle-all",
                    ["ctrl-d"] = "preview-page-down",
                    ["ctrl-u"] = "preview-page-up",
                    ["ctrl-q"] = "select-all+accept",
                },
            },
            files = {
                cwd_prompt = false,
            },
            grep = {
                no_header = true,
            }
        },
        config = function(_, opts)
            require("fzf-lua").setup(opts)

            -- register fzf-lua as default vim.ui.select provider
            local ui_select = require("fzf-lua.providers.ui_select")
            ui_select.register({ winopts = { width = 0.8, height = 0.4 } }, true)
        end,
    },

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
            delay = 500,
            filetypes_denylist = {
                "alpha",
                "dashboard",
                "DiffviewFiles",
                "dirvish",
                "DoomInfo",
                "DressingSelect",
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
            under_cursor = false,
            min_count_to_highlight = 2,
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
            { "é", "<Cmd>HopWord<CR>", desc = "Hop to word", mode = { "n", "v", "o" } },
            { "è", "<Cmd>HopWordMW<CR>", desc = "Hop to word Multi-Window", mode = { "n", "v", "o" } },
            { "t", "<Cmd>HopLineStart<CR>", desc = "Hop to line", mode = { "n", "v", "o" } },
            { "T", "<Cmd>HopLineStartMW<CR>", desc = "Hop to line Multi-Window", mode = { "n", "v", "o" } },
            { "f", "<Cmd>HopChar1CurrentLineAC<CR>", desc = "Hop to char after cursor", mode = { "n", "v", "o" } },
            { "F", "<Cmd>HopChar1CurrentLineBC<CR>", desc = "Hop to char before cursor", mode = { "n", "v", "o" } },
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
        "kylechui/nvim-surround",
        version = "*",
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

    -- Repeat commands
    { "tpope/vim-repeat" },

}
