local ok, better_escape = pcall(require, "better_escape")
if not ok then
    return
end

-- for bépo
better_escape.setup({
    mapping = {"ii", "uu"},
})
