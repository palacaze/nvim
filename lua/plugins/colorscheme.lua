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
            style = "night", -- night, storm, moon or day
            light_style = "day",
            transparent = true,
            terminal_colors = true,
            styles = {
                comments = { italic = true },
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
        lazy = true,
        -- priority = 1000,
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
                    ["markdownH1"] = { fg = colors.palette.springGreen, bold = true, bg = colors.palette.sumiInk0, },
                    ["markdownH2"] = { fg = colors.palette.lotusRed, bold = true,    bg = colors.palette.sumiInk0, },
                    ["markdownH3"] = { fg = colors.palette.crystalBlue, bold = true, bg = colors.palette.sumiInk0, },
                    ["markdownH4"] = { fg = colors.palette.lotusOrange, bold = true, bg = colors.palette.sumiInk0, },
                    ["markdownH5"] = { fg = colors.palette.lotusPink, bold = true,   bg = colors.palette.sumiInk0, },
                    ["markdownH6"] = { fg = colors.palette.oniViolet, bold = true,   bg = colors.palette.sumiInk0, },
                    ["markup.heading.1.markdown"] = { fg = colors.palette.springGreen, bold = true, },
                    ["markup.heading.2.markdown"] = { fg = colors.palette.lotusRed, bold = true, },
                    ["markup.heading.3.markdown"] = { fg = colors.palette.crystalBlue, bold = true, },
                    ["markup.heading.4.markdown"] = { fg = colors.palette.lotusOrange, bold = true, },
                    ["markup.heading.5.markdown"] = { fg = colors.palette.lotusPink, bold = true, },
                    ["markup.heading.6.markdown"] = { fg = colors.palette.oniViolet, bold = true, },
                    ["@comment.documentation.cpp"] = { fg = "#C99484", italic = true, bold = true },
                    ["Comment"] = { fg = "#C99484", italic = true },  -- #D39583  #C99484  #6874A9
                    ["DiffChange"] = { bg = colors.palette.waveBlue1 },
                    ["IncSearch"] = { bg = "#55CB14", fg = "#000000", bold = true },
                    ["Search"] = { bg = "#31A0CF", fg = "#000000", bold = true },
                    ["Visual"] = { bg = "#7c1b60", bold = true },
                    ["WinSeparator"] = { fg = colors.palette.sumiInk6, bg = "NONE" },
                    ["FSPrefix"] = { fg = colors.theme.fg },
                    ["FSSuffix"] = { fg = colors.theme.fg_dim },
                    ["HlSearchLens"] = { bg = "#55CB14", fg = "#000000" },
                    ["SatelliteBar"] = { bg = colors.palette.oniViolet, fg = "NONE" },
                    ["UfoFoldedEllipsis"] = { fg = "#55CB14", bold = true },
                    ["Folded"] = { bg = "NONE" },
                }
            end,
            theme = "wave",
            background = {
                dark = "wave",
                light = "lotus"
            },
        },
        config = function(_, opts)
            -- require("kanagawa").setup(opts)
            -- require("kanagawa").load("wave")
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

    -- One Dark
    {
        "navarasu/onedark.nvim",
        lazy = true,
        -- priority = 1000,
        opts = {
            style = "darker",
        },
        config = function(_, opts)
            require("onedark").setup(opts)
            -- vim.cmd.colorscheme("onedark")
        end
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
        lazy = false,
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavor = "mocha",
                    background = {
                        light = "latte",
                        dark = "mocha",
                },
                transparent_background = false,
                no_italic = true,
                color_overrides = {
                    mocha = {
                        base = "#1d1f21",
                        peach = "#e0af68",
                    },
                },
                custom_highlights = function(C)
                    return {
                        BlinkCmpMenu = { fg = C.overlay0, bg = C.base },
                        BlinkCmpMenuBorder = { fg = C.lavender, bg = C.base },
                        BlinkCmpMenuSelection = { bg = C.surface0 },
                        BlinkCmpSignatureHelpBorder = { fg = C.lavender },
                        BlinkCmpLabel = { fg = C.overlay0 },
                        BlinkCmpLabelDeprecated = { fg = C.overlay0, style = { "strikethrough" } },
                        BlinkCmpDocBorder = { fg = C.lavender, bg = C.base },
                        BlinkCmpDoc = { bg = C.base },
                        BlinkCmpKindText = { fg = C.teal },
                        BlinkCmpKindMethod = { fg = C.blue },
                        BlinkCmpKindFunction = { fg = C.blue },
                        BlinkCmpKindConstructor = { fg = C.blue },
                        BlinkCmpKindField = { fg = C.green },
                        BlinkCmpKindVariable = { fg = C.flamingo },
                        BlinkCmpKindClass = { fg = C.yellow },
                        BlinkCmpKindInterface = { fg = C.yellow },
                        BlinkCmpKindModule = { fg = C.blue },
                        BlinkCmpKindProperty = { fg = C.green },
                        BlinkCmpKindUnit = { fg = C.green },
                        BlinkCmpKindValue = { fg = C.peach },
                        BlinkCmpKindEnum = { fg = C.green },
                        BlinkCmpKindKeyword = { fg = C.red },
                        BlinkCmpKindSnippet = { fg = C.mauve },
                        BlinkCmpKindColor = { fg = C.red },
                        BlinkCmpKindFile = { fg = C.blue },
                        BlinkCmpKindReference = { fg = C.red },
                        BlinkCmpKindFolder = { fg = C.blue },
                        BlinkCmpKindEnumMember = { fg = C.red },
                        BlinkCmpKindConstant = { fg = C.peach },
                        BlinkCmpKindStruct = { fg = C.blue },
                        BlinkCmpKindEvent = { fg = C.blue },
                        BlinkCmpKindOperator = { fg = C.blue },
                        BlinkCmpKindTypeParameter = { fg = C.blue },
                        ["markup.heading.1.markdown"] = { fg = C.blue , bold = true, },
                        ["markup.heading.2.markdown"] = { fg = C.peach , bold = true, },
                        ["markup.heading.3.markdown"] = { fg = C.green , bold = true, },
                        ["markup.heading.4.markdown"] = { fg = C.teal , bold = true, },
                        ["markup.heading.5.markdown"] = { fg = C.mauve , bold = true, },
                        ["markup.heading.6.markdown"] = { fg = C.lavender , bold = true, },

                    }
                end,
                highlight_overrides = {
                    mocha = function(mocha)
                        return {
                            ["@comment.documentation.cpp"] = { fg = "#C99484", bold = true },
                            ["Comment"] = { fg = "#C99484" },  -- #D39583  #C99484  #6874A9
                            ["UfoFoldedEllipsis"] = { fg = "#55CB14", bold = true, bg = "NONE" },
                            ["Folded"] = { bg = "NONE" },
                        }
                   end,
                },

                integrations = {
                    alpha = true,
                    aerial = true,
                    barbar = true,
                    cmp = true,
                    dap = true,
                    dap_ui = true,
                    diffview = true,
                    fidget = true,
                    flash = true,
                    gitsigns = true,
                    grug_far = true,
                    illuminate = true,
                    indent_blankline = { enabled = true },
                    lsp_saga = true,
                    lsp_trouble = true,
                    mason = true,
                    native_lsp = { enabled = true },
                    neotree = true,
                    render_markdown = true,
                    symbols_outline = true,
                    telescope = true,
                    treesitter = true,
                    ufo = true,
                    which_key = true,
                },
            })
            vim.cmd.colorscheme("catppuccin")
        end,
    }

}
