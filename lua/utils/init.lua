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

--- Create a key mapping with a description for the given buffer
--- @param buf integer The buffer id
--- @param modes string All the modes to support, as a string instead of an array
--- @param lhs string The lhs of the mapping
--- @param rhs string | function  The rhs of the mapping
--- @param desc string The description of the mapping
--- @param opts table | nil The mapping options
M.bufmap = function(buf, modes, lhs, rhs, desc, opts)
    opts = opts or { silent = true, noremap = true, nowait = true }
    opts["desc"] = desc
    opts["buffer"] = buf
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

--- Escape key
M.esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)


-- Get selected text or word under cursor
M.get_selection = function()
    local visual = vim.fn.mode() == "v"

    if visual == true then
        local saved_reg = vim.fn.getreg("v")
        vim.cmd([[noautocmd sil norm "vy]])
        local selection = vim.fn.getreg("v")
        vim.fn.setreg("v", saved_reg)
        return selection
    else
        return vim.fn.expand("<cword>")
    end
end

-- The following two function is taken from LazyVim
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/init.lua
-- Returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@return string
M.get_project_root = function()
    ---@type string?
    local path = vim.api.nvim_buf_get_name(0)
    path = path ~= "" and vim.uv.fs_realpath(path) or nil
    ---@type string[]
    local roots = {}
    if path then
        for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
            local workspace = client.config.workspace_folders
            local paths = workspace
                and vim.tbl_map(function(ws)
                    return vim.uri_to_fname(ws.uri)
                end, workspace)
                or client.config.root_dir and { client.config.root_dir }
                or {}
            for _, p in ipairs(paths) do
                local r = vim.uv.fs_realpath(p)
                if path:find(r, 1, true) then
                    roots[#roots + 1] = r
                end
            end
        end
    end
    table.sort(roots, function(a, b)
        return #a > #b
    end)
    ---@type string?
    local root = roots[1]
    if not root then
        path = path and vim.fs.dirname(path) or vim.uv.cwd()
        ---@type string?
        root = vim.fs.find({ ".git", ".clang-format", "pyproject.toml" }, { path = path, upward = true })[1]
        root = root and vim.fs.dirname(root) or vim.uv.cwd()
    end
    ---@cast root string
    return root
end

return M
