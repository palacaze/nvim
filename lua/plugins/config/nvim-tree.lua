local ok, nvim_tree = pcall(require, "nvim-tree")
if not ok then
    return
end

nvim_tree.setup({
    sync_root_with_cwd = true,
    actions = {
        change_dir = {
            global = true,
        },
    },
    view = {
        adaptive_size = true,
        mappings = {
            list = {
                { key = "u", action = "dir_up" },
                { key = ">", action = "cd" },
            },
        },
        side = "right",
    },
    renderer = {
        group_empty = true,
        icons = {
            git_placement = "after",
        },
    },
    filters = {
        dotfiles = true,
    },
})
