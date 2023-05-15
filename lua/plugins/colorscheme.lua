return {

    -- gruvbox
    {
        "ellisonleao/gruvbox.nvim",
        lazy = true,
        opts = {
            contrast = "hard",
            overrides = {
                Folded = { fg = "#fe8301", bg = "None", italic = false },
                -- FoldColumn = { fg = colors.gray, bg = "None" },
            },
        },
    },

    -- tokyonight
    {
        "folke/tokyonight.nvim",
        lazy = true,
        opts = {
            style = "moon", -- night, storm, moon or day
            light_style = "day",
            transparent = false,
            terminal_colors = true,
            styles = {
                comments = { italic = false },
                keywords = { italic = false },
                functions = {},
                variables = {},
                -- Background styles. Can be "dark", "transparent" or "normal"
                sidebars = "dark",
                floats = "dark",
            },
            sidebars = { "qf", "help" }, -- darker background on sidebar-like windows
            day_brightness = 0.3,
            hide_inactive_statusline = false,
            dim_inactive = false,
            lualine_bold = false,
        },
    },

    -- oxocarbon
    {
        "nyoom-engineering/oxocarbon.nvim",
        lazy = true,
    },

    -- kanagawa
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            compile = false,             -- enable compiling the colorscheme
            undercurl = true,            -- enable undercurls
            commentStyle = { italic = false },
            functionStyle = {},
            keywordStyle = { italic = false},
            statementStyle = { bold = true },
            typeStyle = {},
            transparent = false,         -- do not set background color
            dimInactive = false,         -- dim inactive window `:h hl-NormalNC`
            terminalColors = true,       -- define vim.g.terminal_color_{0,17}
            colors = {                   -- add/modify theme and palette colors
                palette = {},
                theme = { wave = {}, lotus = {}, dragon = {}, all = { ui = { bg_gutter = "none" } } },
            },
            overrides = function(colors)
                return {
                    -- custom colors for markup header levels
                    ["@text.title.1"] = { fg = colors.palette.springGreen, bold = true },
                    ["@text.title.2"] = { fg = colors.palette.lotusRed, bold = true },
                    ["@text.title.3"] = { fg = colors.palette.crystalBlue, bold = true },
                    ["@text.title.4"] = { fg = colors.palette.lotusOrange, bold = true },
                    ["@text.title.5"] = { fg = colors.palette.lotusPink, bold = true },
                    ["@text.title.6"] = { fg = colors.palette.oniViolet, bold = true },
                }
            end,
            theme = "wave",              -- Load "wave" theme when 'background' option is not set
            background = {               -- map the value of 'background' option to a theme
                dark = "wave",           -- try "dragon" !
                light = "lotus"
            },
        },
        config = function(_, opts)
            require("kanagawa").setup(opts)
            require("kanagawa").load("wave")
        end,
    },

    -- nightfox
    {
        "EdenEast/nightfox.nvim",
        lazy = true,
        opts = {
            options = {
                transparent = false,
                module_default = true,
            },
        },
        config = function(_, opts)
            require("nightfox").setup(opts)
        end
    },

    -- nordic
    {
        "AlexvZyl/nordic.nvim",
        lazy = true,
    },

    -- dracula
    {
        "Mofiqul/dracula.nvim",
        lazy = true,
        config = function()
            local dracula = require("dracula")
            dracula.setup({
                show_end_of_buffer = false,
                transparent_bg = true,
                -- lualine_bg_color = "#44475a", -- default nil
                italic_comment = false,
                overrides = {
                    -- Normal = { fg = dracula.colors().white, bg = "None" },
                    -- Comment = { fg = "#888888" }
                    -- Examples
                    -- NonText = { fg = dracula.colors().white }, -- set NonText fg to white
                    -- NvimTreeIndentMarker = { link = "NonText" }, -- link to NonText highlight
                    -- Nothing = {} -- clear highlight of Nothing
                },
            })
            -- vim.cmd.colorscheme("dracula-soft")
        end,
    },

    -- gruvbox8
    {
        "lifepillar/vim-gruvbox8",
        lazy = true,
    },

    -- catppuccin
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = true,
        -- priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavor = "mocha",
                    background = {
                        light = "latte",
                        dark = "mocha",
                },
                transparent_background = false,
                no_italic = true,
                integrations = {
                    alpha = true,
                    barbar = true,
                    cmp = true,
                    fidget = true,
                    gitsigns = true,
                    hop = true,
                    illuminate = true,
                    lsp_saga = true,
                    mason = true,
                    neotree = true,
                    symbols_outline = true,
                    telescope = true,
                    treesitter = true,
                    lsp_trouble = true,
                    which_key = true,
                },
            })
            -- vim.cmd.colorscheme("catppuccin")
        end,
    }

}
