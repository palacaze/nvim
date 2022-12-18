local ok, blk = pcall(require, "indent_blankline")
if not ok then
    return
end

vim.cmd [[
    highlight IndentBlanklineChar guifg=#2f2f2f gui=nocombine
]]

local exclude_ft = { "help", "git", "markdown", "snippets", "text", "gitconfig" }

blk.setup {
    char = "▏",
    show_end_of_line = false,
    show_trailing_blankline_indent = false,
    buftype_exclude = { "terminal" },
    filetype_exclude = exclude_ft,
}

local gid = vim.api.nvim_create_augroup("indent_blankline", { clear = true })
vim.api.nvim_create_autocmd("InsertEnter", {
    pattern = "*",
    group = gid,
    command = "IndentBlanklineDisable",
})

vim.api.nvim_create_autocmd("InsertLeave", {
    pattern = "*",
    group = gid,
    callback = function()
        if not vim.tbl_contains(exclude_ft, vim.bo.filetype) then
            vim.cmd([[IndentBlanklineEnable]])
        end
    end,
})
