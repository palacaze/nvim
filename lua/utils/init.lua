local M = {}

--- Create a key mapping with a description
--- @param modes string All the modes to support, as a string instead of an array
--- @param lhs string The lhs of the mapping
--- @param rhs string | function  The rhs of the mapping
--- @param desc string The description of the mapping
--- @param opts table | nil The mapping options
M.map = function(modes, lhs, rhs, desc, opts)
    opts = opts or { silent = true, noremap = true, nowait = true }
    opts["desc"] = desc
    local m = {}
    for i = 1, #modes do
        table.insert(m, string.sub(modes, i, i))
    end
    vim.keymap.set(m, lhs, rhs, opts)
end

--- Test whether a mapping already exist for lhs in mode
--- @param lhs string the key mapping to test
--- @param mode string | nil the mode concerned by the test, defaults to "n"
M.has_mapping = function(lhs, mode)
    return string.len(vim.fn.maparg(lhs, mode)) > 0
end

M.esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)

return M
