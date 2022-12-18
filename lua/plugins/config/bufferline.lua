local ok, bufferline = pcall(require, "bufferline")
if not ok then
    return
end

bufferline.setup({
    options = {
        numbers = "ordinal",
        diagnostics = false,
        show_buffer_icons = false,
        offsets = { { filetype = "NvimTree", text = "File Explorer" } },
        always_show_bufferline = false,
    },
})
