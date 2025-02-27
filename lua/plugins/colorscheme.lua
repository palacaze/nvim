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

    -- gruvbox8
    {
        "lifepillar/vim-gruvbox8",
        lazy = true,
    },

    -- Gruvbox-material
    {
        "sainnhe/gruvbox-material",
        lazy = true,
        config = function()
            vim.g.gruvbox_material_background = "hard"
            vim.g.gruvbox_material_transparent_background = 1
            vim.g.gruvbox_material_better_performance = 1
            vim.g.gruvbox_enable_bold = 1
        end
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

    -- flexoki
    {
        "nuvic/flexoki-nvim",
        name = "flexoki",
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

    -- One Nord
    {
        "rmehri01/onenord.nvim",
        lazy = true,
        opts = {
            disable = {
                background = true,
                float_background = true,
                cursorline = true,
                eob_lines = true,
            },
            custom_highlights = {
                ["@comment.documentation.cpp"] = { fg = "#C99484", bold = true },
                ["Comment"] = { fg = "#C99484" },  -- #D39583  #C99484  #6874A9
                ["UfoFoldedEllipsis"] = { fg = "#55CB14", bold = true, bg = "NONE" },
                ["Folded"] = { bg = "NONE" },
                ["SatelliteBar"] = { fg = "#957FB8", bg = "NONE" },
                ["SatelliteBackground"] = { fg = "#957FB8", bg = "NONE" },
                BlinkCmpMenu = { fg = "#6c7086", bg = "#1e1e2e" },
                BlinkCmpMenuBorder = { fg = "#b4befe", bg = "#1e1e2e" },
                BlinkCmpMenuSelection = { bg = "#b313244" },
                BlinkCmpSignatureHelpBorder = { fg = "#b4befe" },
                BlinkCmpLabel = { fg = "#6c7086" },
                BlinkCmpLabelDeprecated = { fg = "#6c7086" },
                BlinkCmpDocBorder = { fg = "#b4befe", bg = "#1e1e2e" },
                BlinkCmpDoc = { bg = "#1e1e2e" },
                BlinkCmpKindText = { fg = "#b94e2d5" },
                BlinkCmpKindMethod = { fg = "#89b4fa" },
                BlinkCmpKindFunction = { fg = "#89b4fa" },
                BlinkCmpKindConstructor = { fg = "#89b4fa" },
                BlinkCmpKindField = { fg = "#a6e3a1" },
                BlinkCmpKindVariable = { fg = "#f2cdcd" },
                BlinkCmpKindClass = { fg = "#f9e2af" },
                BlinkCmpKindInterface = { fg = "#f9e2af" },
                BlinkCmpKindModule = { fg = "#89b4fa" },
                BlinkCmpKindProperty = { fg = "#a6e3a1" },
                BlinkCmpKindUnit = { fg = "#a6e3a1" },
                BlinkCmpKindValue = { fg = "#fab387" },
                BlinkCmpKindEnum = { fg = "#a6e3a1" },
                BlinkCmpKindKeyword = { fg = "#f38ba8" },
                BlinkCmpKindSnippet = { fg = "#cba6f7" },
                BlinkCmpKindColor = { fg = "#f38ba8" },
                BlinkCmpKindFile = { fg = "#89b4fa" },
                BlinkCmpKindReference = { fg = "#f38ba8" },
                BlinkCmpKindFolder = { fg = "#89b4fa" },
                BlinkCmpKindEnumMember = { fg = "#f38ba8" },
                BlinkCmpKindConstant = { fg = "#fab387" },
                BlinkCmpKindStruct = { fg = "#89b4fa" },
                BlinkCmpKindEvent = { fg = "#89b4fa" },
                BlinkCmpKindOperator = { fg = "#89b4fa" },
                BlinkCmpKindTypeParameter = { fg = "#89b4fa" },
                ["markup.heading.1.markdown"] = { fg = "#89b4fa" , bold = true, },
                ["markup.heading.2.markdown"] = { fg = "#fab387" , bold = true, },
                ["markup.heading.3.markdown"] = { fg = "#a6e3a1" , bold = true, },
                ["markup.heading.4.markdown"] = { fg = "#b94e2d5" , bold = true, },
                ["markup.heading.5.markdown"] = { fg = "#cba6f7" , bold = true, },
                ["markup.heading.6.markdown"] = { fg = "#b4befe" , bold = true, },
            },
        }
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
                        -- text = "#dbdbb2",
                        -- base = "#211f1d",
                        peach = "#e0af68",
                    },
                },
                custom_highlights = function(C)
                    return {
                        ["markup.heading.1.markdown"] = { fg = C.blue , bold = true, },
                        ["markup.heading.2.markdown"] = { fg = C.peach , bold = true, },
                        ["markup.heading.3.markdown"] = { fg = C.green , bold = true, },
                        ["markup.heading.4.markdown"] = { fg = C.teal , bold = true, },
                        ["markup.heading.5.markdown"] = { fg = C.mauve , bold = true, },
                        ["markup.heading.6.markdown"] = { fg = C.lavender , bold = true, },
                        CmpItemAbbrMatch = { fg = C.blue, style = { "bold" } },
                        CmpItemAbbrMatchFuzzy = { fg = C.blue, style = { "bold" } },
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
                    blink_cmp = true,
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
