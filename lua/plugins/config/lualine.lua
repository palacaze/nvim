local ok, lualine = pcall(require, "lualine")
if not ok then
    return
end

local function trailing_space()
    if not vim.o.modifiable then
        return ""
    end
    local space = vim.fn.search([[\s\+$]], "nwc")
    return space ~= 0 and "TW:" .. space or ""
end

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
    if mixed_same_line ~= nil and mixed_same_line > 0 then
        return "MI:" .. mixed_same_line
    end
    local space_indent_cnt = vim.fn.searchcount({ pattern = space_pat, max_count = 1e3 }).total
    local tab_indent_cnt = vim.fn.searchcount({ pattern = tab_pat, max_count = 1e3 }).total
    if space_indent_cnt > tab_indent_cnt then
        return "MI:" .. tab_indent
    else
        return "MI:" .. space_indent
    end
end

lualine.setup({
    options = {
        icons_enabled = true,
        theme = "auto",
        section_separators = "",
        component_separators = "",
    },
    sections = {
        lualine_z = {
            "location",
            {
                trailing_space,
                color = "WarningMsg",
            },
            {
                mixed_indent,
                color = "WarningMsg",
            },
        },
    },
    extensions = {
        "quickfix",
        "neo-tree",
        "aerial",
        "fugitive",
        "toggleterm",
    },
})
