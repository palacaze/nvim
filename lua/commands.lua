local function nvim_create_commands(definitions)
    for group_name, definition in pairs(definitions) do
        vim.api.nvim_create_augroup(group_name, {clear = true})
        for _, def in ipairs(definition) do
            def["group"] = group_name
            vim.api.nvim_create_autocmd(def[1], def[2])
        end
    end
end

nvim_create_commands({
    markdown_syntax = {
        { "FileType", {
            pattern = {"markdown", "txt"},
            callback = function()
                vim.opt_local.wrap = true
                vim.opt_local.spell = true
                vim.opt_local.spelllang = "en"
            end
        }}
    },

    -- disable search highlighting on startup
    nohl = {
        { "VimEnter", { pattern = "*", command = [[let @/ = '']] }}
    },

    -- format go files on save
    format_go = {
        { "BufWritePre", {
            pattern = "*.go",
            callback = function()
                require('go.format').goimport()
            end
        }}
    },
})

