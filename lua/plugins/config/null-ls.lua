local ok, nls = pcall(require, "null-ls")
if not ok then
    return
end

local nls_utils = require("null-ls.utils")
local b = nls.builtins

local with_diagnostics_code = function(builtin)
    return builtin.with({
        diagnostics_format = "#{m} [#{c}]",
    })
end

local with_root_file = function(builtin, file)
    return builtin.with({
        condition = function(utils)
            return utils.root_has_file(file)
        end,
    })
end

local sources = {
    -- formatting
    b.formatting.black.with({ extra_args = { "--fast" } }),
    b.formatting.isort,
    with_root_file(b.formatting.stylua, "stylua.toml"),

    -- diagnostics
    b.diagnostics.jsonlint,
    b.diagnostics.markdownlint,
    b.diagnostics.flake8,
    with_diagnostics_code(b.diagnostics.shellcheck),

    -- code actions
    b.code_actions.gitsigns,
    b.code_actions.gitrebase,
    b.code_actions.shellcheck,
}

nls.setup({
    save_after_format = false,
    sources = sources,
    root_dir = nls_utils.root_pattern(".git"),
})

