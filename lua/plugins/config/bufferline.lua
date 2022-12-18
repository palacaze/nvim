local ok, bufferline = pcall(require, "bufferline")
if not ok then
    return
end

-- Improve highlight groups 
vim.cmd[[
    highlight! link BufferLineBufferSelected Visual
    highlight! link BufferLineNumbersSelected Visual
    highlight! link BufferLineIndicatorSelected Visual
    highlight! link BufferLineCloseButtonSelected Visual
    highlight! link BufferLineTabSeparatorSelected Visual
    highlight! link BufferLineModifiedSelected Visual
]]

bufferline.setup({
    options = {
        numbers = "ordinal",
        diagnostics = false,
        show_buffer_icons = false,
        show_close_icon = false,
        separator_style = "thin",
        buffer_close_icon = "",
        offsets = {
            { filetype = "NvimTree", text = "File Explorer" },
            { filetype = "neo-tree", text = "File Explorer" },
        },
        always_show_bufferline = false,
        hover = {
            enabled = true,
            delay = 200,
            reveal = {'close'}
        },
        indicator = {
            icon = "",
            style = "none",
        },
    },
})
