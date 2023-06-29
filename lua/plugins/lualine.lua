-- Lualine status line
return {
    "nvim-lualine/lualine.nvim",
    event = "UIEnter",
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
            globalstatus = false,
            icons_enabled = true,
            theme = "pal",
            disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        },
        sections = {
            lualine_a = {
                {
                    "mode",
                    fmt = function(str) return str:sub(1, 1) end,
                },
            },
            lualine_b = {
                {
                    -- spell
                    function() return require("config.icons").ui.Spell .. vim.bo.spelllang end,
                    cond = function() return vim.opt_local.spell:get() end,
                    padding = { left = 1, right = 0 },
                },
            },
            lualine_c = {
                {
                    -- Get git branch from gitsigns
                    "b:gitsigns_head",
                    icon = require("config.icons").git.Branch,
                    color = { fg = "#A292B3" },
                    padding = { left = 1, right = 0 },
                },
                {
                    -- Get git diff from gitsigns
                    "diff",
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
                {
                    "filetype",
                    icon_only = true,
                },
                {
                    "filename",
                    color = { gui = "bold" },
                }
            },
            lualine_x = {
                {
                    "diagnostics",
                    symbols = {
                        error = require("config.icons").diagnostics.Error,
                        warn = require("config.icons").diagnostics.Warning,
                        info = require("config.icons").diagnostics.Information,
                    },
                    sections = { "error", "warn", "info" },
                },
            },
            lualine_y = {
                {
                    "encoding",
                    padding = 0,

                },
                {
                    "fileformat",
                    icons_enabled = true,
                },
            },
            lualine_z = {
                "progress",
                "location",
                {
                    "b:pal_trailing_spaces",
                    color = { fg = "#111111", bg = "#FF9E3B", gui = "bold" },
                },
                {
                    "b:pal_mixed_indent",
                    color = { fg = "#111111", bg = "#FF9E3B", gui = "bold" },
                },
            },
        },
        inactive_sections = {
            lualine_a = {
                {
                    "filetype",
                    icon_only = true,
                },
                {
                    "filename",
                    color = { gui = "bold" },
                }
            },
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
            "nvim-dap-ui",
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
                        { "mode", fmt = function(str) return str:sub(1, 1) end },
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
}
