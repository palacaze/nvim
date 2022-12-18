local ok, true_zen = pcall(require, "true-zen")
if not ok then
    return
end

true_zen.setup({
    integrations = {
        tmux = true,
        gitsigns = true,
        lualine = true,
    },
})
