local ok, catppuccin = pcall(require, "catppuccin")
if not ok then
    return
end

catppuccin.setup({
    transparent_background = true,
    compile = {
        enabled = false,
        path = vim.fn.stdpath("cache") .. "/catppuccin",
        suffix = "_compiled",
    },
    -- styles = {
    --     comments = { "italic" },
    --     conditionals = { "italic" },
    --     loops = {},
    --     functions = {},
    --     keywords = {},
    --     strings = {},
    --     variables = {},
    --     numbers = {},
    --     booleans = {},
    --     properties = {},
    --     types = {},
    --     operators = {},
    -- },
    integrations = {
        treesitter = true,
        native_lsp = {
            enabled = true,
            virtual_text = {
                errors = { "italic" },
                hints = { "italic" },
                warnings = { "italic" },
                information = { "italic" },
            },
            underlines = {
                errors = { "underline" },
                hints = { "underline" },
                warnings = { "underline" },
                information = { "underline" },
            },
        },
        -- coc_nvim = false,
        lsp_trouble = true,
        cmp = true,
        -- lsp_saga = false,
        -- gitgutter = false,
        gitsigns = true,
        telescope = true,
        nvimtree = {
            enabled = true,
            show_root = true,
            transparent_panel = false,
        },
        neotree = {
            enabled = true,
            show_root = true,
            transparent_panel = false,
        },
        -- dap = {
        --     enabled = false,
        --     enable_ui = false,
        -- },
        which_key = true,
        indent_blankline = {
            enabled = true,
            colored_indent_levels = false,
        },
        -- dashboard = true,
        -- neogit = false,
        -- vim_sneak = false,
        -- fern = false,
        -- barbar = false,
        bufferline = true,
        markdown = true,
        -- lightspeed = false,
        -- ts_rainbow = false,
        -- hop = false,
        notify = true,
        -- telekasten = true,
        -- symbols_outline = true,
        -- mini = false,
    },
})
