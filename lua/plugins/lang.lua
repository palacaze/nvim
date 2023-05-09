return {

    -- Go development plugin for Vim
    {
        "ray-x/go.nvim",
        ft = "go",
        config = true,
        init = function()
            -- reformat go files on save
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("go_format", { clear = true }),
                pattern = "*.go",
                callback = function() require('go.format').goimport() end,
            })
        end,
    },

    -- Python indent (follows the PEP8 style)
    {
        "Vimjas/vim-python-pep8-indent",
        ft = { "python" },
    },

    -- Python-related text object
    {
        "jeetsukumaran/vim-pythonsense",
        ft = { "python" },
    },

    -- Sphinx / reST support
    {
        "stsewd/sphinx.nvim",
        build = ":UpdateRemotePlugins" 
    },

    -- Extended Vim syntax highlighting for C and C++
    {
        "bfrg/vim-cpp-modern",
        ft = { "c", "cpp", "cuda" },
    },

    -- Vim configuration for Zig
    {
        "ziglang/zig.vim",
        ft = { "zig" },
    },

    -- PlantUML stuff
    { "aklt/plantuml-syntax" },
    { "tyru/open-browser.vim" },
    { "weirongxu/plantuml-previewer.vim" },

    -- Gentoo and portage related syntax highlighting, filetype, and indent settings for vim
    { "gentoo/gentoo-syntax" }

    -- Syntax highlighting, matching rules and mappings for the original Markdown and extensions
    -- use("preservim/vim-markdown")

}
