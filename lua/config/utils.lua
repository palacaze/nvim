local M = {}

--- Create a key mapping with a description
M.map = function(modes, lhs, rhs, desc, opts)
    opts = opts or { silent = true, noremap = true, nowait = true }
    opts["desc"] = desc
    vim.keymap.set(modes, lhs, rhs, opts)
end

--- Create a key mapping in n mode, with a description.
M.map_n = function(lhs, rhs, desc, opts)
    M.map("n", lhs, rhs, desc, opts)
end

--- Create a key mapping in v mode, with a description.
M.map_v = function(lhs, rhs, desc, opts)
    M.map("v", lhs, rhs, desc, opts)
end

--- Create a key mapping in i mode, with a description.
M.map_i = function(lhs, rhs, desc, opts)
    M.map("i", lhs, rhs, desc, opts)
end

--- Create a key mapping in t mode, with a description.
M.map_t = function(lhs, rhs, desc, opts)
    M.map("t", lhs, rhs, desc, opts)
end

--- Create a key mapping in n and v modes, with a description.
M.map_nv = function(lhs, rhs, desc, opts)
    M.map({ "n", "v" }, lhs, rhs, desc, opts)
end

--- Create a key mapping in n and i modes, with a description.
M.map_ni = function(lhs, rhs, desc, opts)
    M.map({ "n", "i" }, lhs, rhs, desc, opts)
end

--- Create a key mapping in n, v and i modes, with a description.
M.map_nvi = function(lhs, rhs, desc, opts)
    M.map({ "n", "v", "i" }, lhs, rhs, desc, opts)
end

-- Test whether a mapping already exist for lhs in mode
M.has_mapping = function(lhs, mode)
    return string.len(vim.fn.maparg(lhs, mode)) > 0
end

M.esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)

-- A function to trim trailing spaces
function M.strip_trailing_spaces()
    local save = vim.fn.winsaveview()
    vim.api.nvim_exec("keepjumps keeppatterns silent! %s/\\s\\+$//e", false)
    vim.fn.winrestview(save)
end

-- Detect training spaces and returns a string telling giving offender
function M.trailing_spaces()
    if not vim.o.modifiable then
        return ""
    end
    local space = vim.fn.search([[\s\+$]], "nwc")
    return space ~= 0 and "TW:" .. space or ""
end

-- Detect mixed indents
-- Report either the first line with both spaces and tabs, or the first line
-- not conforming to the majority of indented lines.
function M.mixed_indent()
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

return M
