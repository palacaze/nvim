return {

    -- A buffer line
    {
        "romgrk/barbar.nvim",
        dependencies = { "gitsigns.nvim", "nvim-web-devicons" },
        lazy = true,
        event = {"BufNewFile", "BufReadPost", "SessionLoadPost", "TabEnter"},
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
        init = function()
            vim.g.barbar_auto_setup = false
        end,
        opts = {
            animation = false,
            auto_hide = true,
            tabpages = true,
            closable = true,
            icons = {
                button = false,
                separator = { left = require("config.icons").ui.LeftSeparator },
                modified = { button = require("config.icons").ui.Modified },
                pinned = { button =require("config.icons").ui.Pinned },
                filetype = { enabled = true },
                diagnostics = {
                    { enabled = false }, -- ERROR
                    { enabled = false }, -- WARN
                    { enabled = false }, -- INFO
                    { enabled = false }, -- HINT
                },
            },
            exclude_ft = { "neo-tree", "Trouble", "qf" },
            -- exclude_name = {"package.json"},
            hide = { extensions = false, inactive = false },
            highlight_alternate = false,
            highlight_visible = true,
            sidebar_filenames = {
                ["neo-tree"] = {event = "BufWipeout"},
            },
            letters = "ecitusaranmovpdélbjzkqxgyhàfECITUSARANMOVPDÉLBJZKQXGYHÀF",
        },
    },

    -- scrollbars
    {
        "lewis6991/satellite.nvim",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            winblend = 70,
            width = 1,
            excluded_filetypes = {
                "alpha",
                "prompt",
                "TelescopePrompt",
                "noice",
                "guihua",
                "neo-tree",
                "neo-tree-popup",
                "toggleterm",
                "Trouble",
            },
            handlers = {
                cursor = { enable = false },
                marks = { enable = false },
                gitsigns = {
                    enable = true,
                    signs = {
                        add = "▕",
                        change = "▕",
                    }
                }
            },
            signs_on_startup = { "diagnostics", "search", "conflicts" },
        },
    },

    -- dashboard
    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        opts = function()
            local icons = require("config.icons")
            local dashboard = require("alpha.themes.dashboard")
            dashboard.section.header.val = {
                [[███    ██ ███████  ██████  ██    ██ ██ ███    ███]],
                [[████   ██ ██      ██    ██ ██    ██ ██ ████  ████]],
                [[██ ██  ██ █████   ██    ██ ██    ██ ██ ██ ████ ██]],
                [[██  ██ ██ ██      ██    ██  ██  ██  ██ ██  ██  ██]],
                [[██   ████ ███████  ██████    ████   ██ ██      ██]]
            }
            dashboard.section.buttons.val = {
                dashboard.button("f", icons.ui.Search .. " Find file", "<Leader><Space>",
                    { remap = true, silent = true, nowait = true }),
                dashboard.button("n", icons.ui.File .. " New file", ":silent enew <BAR> startinsert<CR>"),
                dashboard.button("r", icons.ui.History .. " Recent files", "<Leader>fr",
                    { remap = true, silent = true, nowait = true }),
                dashboard.button("g", icons.ui.List .. " Find text", "<Leader>/",
                    { remap = true, silent = true, nowait = true }),
                dashboard.button("c", icons.ui.Gear .. " Config", ":e $MYVIMRC<CR>"),
                dashboard.button("l", icons.ui.Lazy .. " Lazy", ":Lazy<CR>"),
                dashboard.button("q", icons.ui.Quit .. " Quit", ":qa<CR>"),
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

    -- Get a list of URLs to pick from
    {
        "axieax/urlview.nvim",
        dependencies = { "fzf-lua" },
        cmd = { "UrlView" },
        keys = {
            { "<Leader>u", "<Cmd>UrlView<CR>", desc = "View buffer URLs" },
        },
        opts = {
            default_picker = "native",
        },
    },

    -- Icons, for neo-tree and others
    { "nvim-tree/nvim-web-devicons", lazy = true },
    { "nvim-mini/mini.icons", lazy = true, version = false },

    -- UI components, for neo-tree
    { "MunifTanjim/nui.nvim", lazy = true },

    -- UI components for lspsaga && go
    {
        "ray-x/guihua.lua",
        lazy = true,
        build = "cd lua/fzy && make",
    },

    {
        "stevearc/dressing.nvim",
        opts = {
            input = { enabled = false },
        },
    },
}
