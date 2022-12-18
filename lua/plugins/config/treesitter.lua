local ok, treesitter = pcall(require, "nvim-treesitter.configs")
if not ok then
    return
end

treesitter.setup({
    ensure_installed = {
        "bash",
        "c",
        "cmake",
        "cpp",
        "css",
        "cuda",
        "dockerfile",
        "go",
        "html",
        -- "json",
        "lua",
        "make",
        "norg",
        "proto",
        "python",
        "rust",
        "sql",
        "toml",
        "vim",
        "zig",
    },
    ignore_install = {},
    autopairs = {
        enable = true,
    },
    highlight = {
        enable = true,
        disable = {},
    },
    indent = {
        enable = true,
        disable = {},
    },
    context_commentstring = {
        enable = true,
        enable_autocmd = false,
    },
})
