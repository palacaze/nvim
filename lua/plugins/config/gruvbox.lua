local ok, gruvbox = pcall(require, "gruvbox")
if not ok then
    return
end

gruvbox.setup({
    contrast = "hard",
    overrides = {
        Folded = { fg = "#fe8301", bg = "None", italic = true },
        -- FoldColumn = { fg = colors.gray, bg = "None" },
    },
})

