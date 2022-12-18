local M = {}

--- Create a key mapping with a description
M.map = function(modes, lhs, rhs, desc, opts)
    opts = opts or { silent = true, noremap = true }
    opts["desc"] = desc
    vim.keymap.set(modes, lhs, rhs, opts)
end

--- Create a key mapping in n mode, with a description.
M.map_n = function(lhs, rhs, desc, opts)
    M.map("n", lhs, rhs, desc, opts)
end

--- Create a key mapping in v mode, with a description.
M.map_v = function(lhs, rhs, desc, opts)
    M.map("x", lhs, rhs, desc, opts)
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
    M.map({ "n", "x" }, lhs, rhs, desc, opts)
end

--- Create a key mapping in n and i modes, with a description.
M.map_ni = function(lhs, rhs, desc, opts)
    M.map({ "n", "i" }, lhs, rhs, desc, opts)
end

--- Create a key mapping in n, v and i modes, with a description.
M.map_nvi = function(lhs, rhs, desc, opts)
    M.map({ "n", "x", "i" }, lhs, rhs, desc, opts)
end

M.esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)

return M
