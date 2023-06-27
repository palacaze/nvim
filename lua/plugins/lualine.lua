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
                    function() return require("config.icons").ui.Spell .. vim.bo.spelllang end,
                    cond = function() return vim.opt_local.spell:get() end,
                },
            },
            lualine_b = {
                {
                    "b:gitsigns_head",
                    icon = require("config.icons").git.Branch,
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
