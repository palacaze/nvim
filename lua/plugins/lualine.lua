-- Detect training spaces and returns a string telling giving offender
local function trailing_spaces()
    if not vim.o.modifiable then
        return ""
    end
    local space = vim.fn.search([[\s\+$]], "nwc")
    return space ~= 0 and require("config.icons").ui.Space .. space or ""
end

-- Detect mixed indents
-- Report either the first line with both spaces and tabs, or the first line
-- not conforming to the majority of indented lines.
local function mixed_indent()
    if not vim.o.modifiable then
        return ""
    end
    local space_pat = [[\v^ +]]
    local tab_pat = [[\v^\t+]]
    local space_indent = vim.fn.search(space_pat, "nwc")
    local tab_indent = vim.fn.search(tab_pat, "nwc")
    local mixed = (space_indent > 0 and tab_indent > 0)
    local mixed_same_line
    if not mixed then
        mixed_same_line = vim.fn.search([[\v^(\t+ | +\t)]], "nwc")
        mixed = mixed_same_line > 0
    end
    if not mixed then
        return ""
    end
    local tab_icon = require("config.icons").ui.Tab
    if mixed_same_line ~= nil and mixed_same_line > 0 then
        return tab_icon .. mixed_same_line
    end
    local space_indent_cnt = vim.fn.searchcount({ pattern = space_pat, max_count = 1e3 }).total
    local tab_indent_cnt = vim.fn.searchcount({ pattern = tab_pat, max_count = 1e3 }).total
    if space_indent_cnt > tab_indent_cnt then
        return tab_icon .. tab_indent
    else
        return tab_icon .. space_indent
    end
end

-- Lualine status line
return {
    "nvim-lualine/lualine.nvim",
    event = "UIEnter",
    init = function()
        -- Detect trailing spaces and mixed indent on file saving
        vim.api.nvim_create_autocmd({ "BufWritePost", "BufWinEnter" }, {
            desc = "Detect trailing spaces and mixed indentation",
            group = vim.api.nvim_create_augroup("MyLualineTSMI", { clear = true }),
            pattern = "*",
            callback = function()
                vim.b.pal_mixed_indent = mixed_indent()
                vim.b.pal_trailing_spaces = trailing_spaces()
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
            disabled_filetypes = {
                statusline = {
                    "dashboard",
                    "alpha",
                    "OverseerList",
                }
            },
        },
        sections = {
            lualine_a = {
                {
                    "filetype",
                    icon_only = true,
                    padding = { left = 1, right = 0 },
                },
                {
                    "filename",
                }
            },
            lualine_b = {},
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
            },
            lualine_x = {
                {
                    "overseer",
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
            lualine_y = {
                {
                    -- spell
                    function() return require("config.icons").ui.Spell .. vim.bo.spelllang end,
                    cond = function() return vim.opt_local.spell:get() end,
                },
                {
                    "encoding",
                    padding = 0,
                },
                {
                    "fileformat",
                    icons_enabled = true,
                    padding = { left = 1, right = 2 },
                },
            },
            lualine_z = {
                {
                    "progress",
                },
                {
                    "location",
                    padding = { left = 0, right = 1 },
                },
                {
                    "mode",
                    fmt = function(str) return str:sub(1, 1) end,
                    padding = { left = 0, right = 1 },
                },
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
                    padding = { left = 1, right = 0 },
                },
                {
                    "filename",
                },
            },
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = {
                {
                    "progress",
                },
                {
                    "location",
                    padding = { left = 0, right = 1 },
                },
            },
        },
        extensions = {
            "aerial",
            "fugitive",
            "lazy",
            "mason",
            "neo-tree",
            "nvim-dap-ui",
            "nvim-tree",
            "oil",
            "quickfix",
            "trouble",
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
