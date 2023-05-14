return {

    -- A buffer line
    {
        "romgrk/barbar.nvim",
        dependencies = { "gitsigns.nvim" },
        event = "VimEnter",
        keys = {
            {"<A-Left>", "<Cmd>BufferPrevious<CR>", desc = "Go to previous buffer", mode = {"n", "i", "t"} },
            {"<A-Right>", "<Cmd>BufferNext<CR>", desc = "Go to next buffer", mode = {"n", "i", "t"} },
            { "<Leader>b<Left>", "<Cmd>BufferMovePrevious<CR>", desc = "Move buffer to the left" },
            { "<Leader>b<Right>", "<Cmd>BufferMoveNext<CR>", desc = "Move buffer to the right" },
            { "<C-p>", "<Cmd>BufferPin<CR>", desc = "Pin buffer" },
            { "<M-c>", "<Cmd>BufferClose<CR>", desc = "Close buffer" },
            { "<M-p>", "<Cmd>BufferPick<CR>", desc = "Select a buffer" },
            { "<Leader>bb", "<Cmd>BufferOrderByBufferNumber<CR>", desc = "Order buffers by number" },
            { "<Leader>bd", "<Cmd>BufferOrderByDirectory<CR>", desc = "Order buffers by directory" },
            { "<Leader>bl", "<Cmd>BufferOrderByLanguage<CR>", desc = "Order buffers by language" },
            { "<Leader>bw", "<Cmd>BufferOrderByWindowNumber<CR>", desc = "Order buffers by window number" },
        },
        init = function() vim.g.barbar_auto_setup = false end,
        opts = {
            animation = false,
            auto_hide = true,
            tabpages = true,
            closable = true,
            icons = {
                button = "",
                separator = { left = "▎" },
                modified = { button = "●", },
                pinned = { button = "車", },
                filetype = { enabled = true },
                diagnostics = {
                    { enabled = false }, -- ERROR
                    { enabled = false }, -- WARN
                    { enabled = false }, -- INFO
                    { enabled = false }, -- HINT
                },
            },
            exclude_ft = { "neo-tree", "Trouble" },
            -- exclude_name = {"package.json"},
            hide = {extensions = false, inactive = false},
            highlight_alternate = false,
            highlight_visible = true,
            sidebar_filenames = {
                ['neo-tree'] = {event = 'BufWipeout'},
            },
            letters = "ecitusaranmovpdélbjzkqxgyhàfECITUSARANMOVPDÉLBJZKQXGYHÀF",
        },
    },

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        init = function()
            -- Detect trailing spaces and mixed indent on file saving
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufWinEnter" }, {
                desc = "Detect trailing spaces and mixed indentation",
                group = vim.api.nvim_create_augroup("MyLualineTSMI", {}),
                pattern = "*",
                callback = function()
                    local u = require("config.utils")
                    vim.b.pal_mixed_indent = u.mixed_indent()
                    vim.b.pal_trailing_spaces = u.trailing_spaces()
                end,
            })
        end,
        opts = {
            options = {
                component_separators = "",
                section_separators = "",
                globalstatus = true,
                icons_enabled = true,
                theme = "auto",
                disabled_filetypes = { statusline = { "dashboard", "alpha" } },
            },
            sections = {
                lualine_a = {
                    {
                        "mode",
                    },
                    {
                        -- spell
                        function()
                            if vim.wo.spell then
                                local lang = vim.bo.spelllang
                                if lang ~= "" then
                                    return "暈" .. lang
                                end
                                return "暈"
                            end
                            return ""
                        end,
                        color = "Normal",
                    },
                },
                lualine_b = {
                    {
                        "b:gitsigns_head",
                        icon = "",
                    },
                    {
                        "diff",
                        -- use gitsigns as diff source
                        source = function()
                            local gitsigns = vim.b.gitsigns_status_dict
                            if gitsigns then
                                return {
                                    added = gitsigns.added,
                                    modified = gitsigns.changed,
                                    removed = gitsigns.removed,
                                }
                            end
                        end,
                    },
                    "diagnostics",
                },
                lualine_c = { "filetype", "filename" },
                lualine_x = { "encoding", "fileformat" },
                lualine_y = { "progress", "location" },
                lualine_z = {
                    {
                        "b:pal_trailing_spaces",
                        color = "WarningMsg",
                    },
                    {
                        "b:pal_mixed_indent",
                        color = "WarningMsg",
                    },
                },
            },
            inactive_sections = {
                lualine_a = { "filetype", "filename" },
                lualine_b = {},
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = { "location" },
            },
            extensions = {
                "quickfix",
                "neo-tree",
                "nvim-tree",
                "aerial",
                "fugitive",
                "lazy",
                -- diffview extension
                {
                    filetypes = { "DiffviewFiles" },
                    sections = {
                        lualine_a = { function() return "DiffView" end },
                    },
                },
                -- term extension
                {
                    filetypes = { "toggleterm" },
                    sections = {
                        lualine_a = {
                            function()
                                -- `pal_term_name` was created by us in toggleterm.lua,
                                -- `toggle_number` was set by the toggleterm plugin.
                                return vim.b.pal_term_name .. " (Term #" .. vim.b.toggle_number .. ")"
                            end
                        },
                    },
                },
            },
        },
    },

    -- Window names with global statusbar
    {
        "b0o/incline.nvim",
        event = "BufReadPre",
        opts = {
            hide = {
                cursorline = true,
                focused_win = false,
                only_win = true,
            },
            highlight = {
                groups = {
                    InclineNormal = { guibg = "#AC8681", guifg = "#161616" },
                    InclineNormalNC = { guifg = "#AC8681", guibg = "#161616" },
                },
            },
            window = { margin = { vertical = 0, horizontal = 1 } },
            render = function(props)
                local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
                local icon, color = require("nvim-web-devicons").get_icon_color(filename)
                return { { icon, guifg = color }, { " " }, { filename } }
            end,
        },
    },

    -- Scrollbars
    {
        "petertriho/nvim-scrollbar",
        dependencies = { "nvim-hlslens" },
        event = "BufReadPost",
        opts = {
            excluded_filetypes = {
                "alpha",
                "prompt",
                "TelescopePrompt",
                "noice",
                "guihua",
                "neo-tree",
                "neo-tree-popup",
                "Trouble",
            },
            excluded_buftypes = {
                "terminal",
                "prompt",
                "nofile",
            },
            handlers = {
                cursor = true,
                diagnostic = true,
                gitsigns = false,
                handle = true,
                search = true,
            },
        },
    },

    -- File explorer
    {
        "nvim-neo-tree/neo-tree.nvim",
        cmd = "Neotree",
        keys = {
            { "<M-e>", "<Cmd>Neotree focus<CR>", desc = "Focus File Explorer", mode = { "n", "i" } },
            { "<F5>", "<Cmd>Neotree toggle<CR>", desc = "Toggle File Explorer", mode = { "n", "i" } },
        },
        deactivate = function()
            vim.cmd([[Neotree close]])
        end,
        init = function()
            vim.g.neo_tree_remove_legacy_commands = 1
            -- open neo-tree if vim was set to open a directory
            if vim.fn.argc() == 1 then
                local stat = vim.loop.fs_stat(vim.fn.argv(0))
                if stat and stat.type == "directory" then
                    require("neo-tree")
                end
            end
        end,
        opts = {
            sources = {
                "filesystem",
                "buffers",
                "git_status",
            },
            close_if_last_window = true,
            enable_diagnostics = false,
            enble_git_status = true,
            sort_case_insensitive = true,
            use_popups_for_input = false,
            source_selector = {
                winbar = true,
                content_layout = "center",
            },
            default_component_configs = {
                container = {
                    enable_character_fade = true,
                },
                indent = {
                    padding = 0,
                    with_markers = false,
                },
                icon = {
                    folder_closed = "",
                    folder_open   = "",
                    folder_empty  = "ﰊ",
                },
                name = {
                    trailing_slash = true,
                    use_git_status_colors = false,
                },
                git_status = {
                    symbols = {
                        added     = "",
                        modified  = "",
                        deleted   = "",
                        renamed   = "",
                        untracked = "留",
                        ignored   = "∅",
                        unstaged  = "✗",
                        staged    = "✓",
                        conflict  = "",
                    },
                },
            },
            window = {
                width = 30,
                mappings = {
                    ["<space>"] = {
                        "toggle_node",
                        nowait = false,
                    },
                    ["o"] = "open",
                    ["<Left>"] = "prev_source",
                    ["<Right>"] = "next_source",
                    ["<C-v>"] = "open_vsplit",
                    ['<tab>'] = function (state)
                        local node = state.tree:get_node()
                        if require("neo-tree.utils").is_expandable(node) then
                            state.commands["toggle_node"](state)
                        else
                            state.commands['open'](state)
                            vim.cmd('Neotree reveal')
                        end
                    end,
                },
            },
            filesystem = {
                follow_current_file = true,
                hijack_netrw_behavior = "open_current",
                use_libuv_file_watcher = true,
                window = {
                    mappings = {
                        ["h"] = "toggle_hidden",
                        ["ga"] = "git_add_file",
                        ["gu"] = "git_unstage_file",
                    },
                },
            },
        },
        config = function(_, opts)
            require("neo-tree").setup(opts)
            -- update tree git status after lazygit invocation
            vim.api.nvim_create_autocmd("TermClose", {
                pattern = "*lazygit",
                callback = function()
                    if package.loaded["neo-tree.sources.git_status"] then
                        require("neo-tree.sources.git_status").refresh()
                    end
                end,
            })
        end,
    },

    -- A neovim lua plugin to help easily manage multiple terminal windows
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        keys = {
            { "<Leader>Tt", desc = "Start a shell in a terminal" },
            { "<Leader>Tg", desc = "Run lazygit in a floating terminal" },
            { "<F12>", desc = "Run lazygit in a floating terminal", mode = { "n", "t" } },
            { "<Leader>Tp", desc = "Run python3 in a terminal" },
            { "<S-F1>", desc = "Send current line to terminal", mode = { "n", "i" } },
            { "<S-F1>", desc = "Send selection to terminal", mode = "v" },
        },
        opts = {
            open_mapping = "<F1>",
            shade_terminals = false,
            start_in_insert = true,
            -- Create a buffer variable "pal_term_name" containing the terminal "name"
            -- on opening. This name will be used by lualine to display a nicer label.
            on_open = function(term)
                vim.api.nvim_buf_set_var(term.bufnr, "pal_term_name", term.term_name)
            end
        },
        config = function(_, opts)
            require("toggleterm").setup(opts)

            -- Custom terminals
            local Terminal = require("toggleterm.terminal").Terminal

            local lazygit = Terminal:new({
                cmd = "lazygit",
                direction = "tab",
                close_on_exit = true,
                float_opts = {
                    border = "single",
                    winblend = 0,
                },
                term_name = "Lazygit",
            })

            local toggle_lazygit = function()
                lazygit:toggle()
            end

            local shell = Terminal:new({
                direction = "horizontal",
                close_on_exit = true,
                term_name = "Shell",
            })

            local toggle_shell = function()
                shell:toggle()
            end

            local python = Terminal:new({
                cmd = "ipython",
                direction = "horizontal",
                close_on_exit = true,
                term_name = "IPython",
            })

            local toggle_python = function()
                python:toggle()
            end

            local u = require("config.utils")
            u.map_n("<Leader>Tt", toggle_shell, "Start a shell in a terminal")
            u.map_n("<Leader>Tg", toggle_lazygit, "Run lazygit in a floating terminal")
            u.map({"n", "t"}, "<F12>", toggle_lazygit, "Run lazygit in a floating terminal")
            u.map_n("<Leader>Tp", toggle_python, "Run python3 in a terminal")
            u.map_ni("<S-F1>", "<Cmd>ToggleTermSendCurrentLine<CR>", "Send current line to terminal")
            u.map_v("<S-F1>", "<Cmd>ToggleTermSendVisualSelection<CR>", "Send selection to terminal")
        end,

    },

    -- dashboard
    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        opts = function()
            local dashboard = require("alpha.themes.dashboard")
            dashboard.section.header.val = {
                [[███    ██ ███████  ██████  ██    ██ ██ ███    ███]],
                [[████   ██ ██      ██    ██ ██    ██ ██ ████  ████]],
                [[██ ██  ██ █████   ██    ██ ██    ██ ██ ██ ████ ██]],
                [[██  ██ ██ ██      ██    ██  ██  ██  ██ ██  ██  ██]],
                [[██   ████ ███████  ██████    ████   ██ ██      ██]]
            }
            dashboard.section.buttons.val = {
                dashboard.button("f", " " .. " Find file", ":Telescope find_files <CR>"),
                dashboard.button("n", " " .. " New file", ":ene <BAR> startinsert <CR>"),
                dashboard.button("r", " " .. " Recent files", ":Telescope oldfiles <CR>"),
                dashboard.button("g", " " .. " Find text", ":Telescope live_grep <CR>"),
                dashboard.button("c", " " .. " Config", ":e $MYVIMRC <CR>"),
                dashboard.button("l", "󰒲 " .. " Lazy", ":Lazy<CR>"),
                dashboard.button("q", " " .. " Quit", ":qa<CR>"),
            }
            return dashboard
        end,
        config = function(_, dashboard)
            -- close Lazy and re-open when the dashboard is ready
            if vim.o.filetype == "lazy" then
                vim.cmd.close()
                vim.api.nvim_create_autocmd("User", {
                    pattern = "AlphaReady",
                    callback = function()
                        require("lazy").show()
                    end,
                })
            end

            require("alpha").setup(dashboard.opts)

            vim.api.nvim_create_autocmd("User", {
                pattern = "LazyVimStarted",
                callback = function()
                    local stats = require("lazy").stats()
                    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                    dashboard.section.footer.val = "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
                    pcall(vim.cmd.AlphaRedraw)
                end,
            })
        end,
    },

    {
        "axieax/urlview.nvim",
        keys = {
            { "<Leader>u", "<Cmd>UrlView<CR>", desc = "View buffer URLs" },
        },
        opts = {
            default_picker = "telescope",
        },
    },

    -- Icons, for neo-tree and others
    { "nvim-tree/nvim-web-devicons", lazy = true },

    -- UI components, for neo-tree
    { "MunifTanjim/nui.nvim", lazy = true },

    -- UI components for lspsaga && go
    {
        "ray-x/guihua.lua",
        lazy = true,
        build = "cd lua/fzy && make",
    },

}
