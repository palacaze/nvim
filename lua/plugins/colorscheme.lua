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
            compile = true,
            undercurl = true,
            commentStyle = { italic = false },
            functionStyle = {},
            keywordStyle = { italic = false},
            statementStyle = { bold = true },
            typeStyle = {},
            transparent = false,
            dimInactive = false,
            terminalColors = true,
            colors = {
                palette = {},
                theme = {
                    wave = {
                        ui = { bg = "#1d1f21" },
                    },
                    lotus = {},
                    dragon = {},
                    all = {
                        ui = { bg_gutter = "none" },
                    }
                },
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
                    ["@comment.documentation.cpp"] = { fg = "#C99484", bold = true },
                    ["Comment"] = { fg = "#C99484" },  -- #D39583  #C99484  #6874A9
                    ["DiffChange"] = { bg = colors.palette.waveBlue1 },
                    ["IncSearch"] = { bg = "#55CB14", fg = "#000000", bold = true },
                    ["Search"] = { bg = "#31A0CF", fg = "#000000", bold = true },
                    ["Visual"] = { bg = "#7c1b60", bold = true },
                    ["WinSeparator"] = { fg = colors.palette.sumiInk6, bg = "NONE" },
                    ["FSPrefix"] = { fg = colors.theme.fg },
                    ["FSSuffix"] = { fg = colors.theme.fg_dim },
                    ["HlSearchLens"] = { bg = "#55CB14", fg = "#000000" },
                    ["UfoFoldedEllipsis"] = { fg = colors.palette.lotusPink },
                }
            end,
            theme = "wave",
            background = {
                dark = "wave",
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
