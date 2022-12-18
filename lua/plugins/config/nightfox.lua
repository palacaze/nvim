local ok, nightfox = pcall(require, "nightfox")
if not ok then
    return
end

nightfox.setup({
    options = {
        transparent = true,
    },
})

