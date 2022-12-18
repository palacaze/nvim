local ok, smart_splits = pcall(require, "smart-splits")
if not ok then
    return
end

smart_splits.setup({
    ignored_filetypes = {
        "nofile",
        "quickfix",
        "qf",
        "prompt",
    },
    ignored_buftypes = { "nofile" },
})

