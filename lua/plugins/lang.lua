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
        ft = { "python", "rst" },
        build = ":UpdateRemotePlugins"
    },

    -- Vim configuration for Zig
    {
        "ziglang/zig.vim",
        ft = { "zig" },
    },

    -- PlantUML stuff
    {
        "aklt/plantuml-syntax",
        ft = { "plantuml", "markdown" },
    },
    {
        "tyru/open-browser.vim",
        lazy = true,
    },
    {
        "weirongxu/plantuml-previewer.vim",
        ft = { "plantuml", "markdown" },
    },

    {
        "iamcco/markdown-preview.nvim",
        ft = { "markdown", "plantuml" },
        build = "cd app && npm install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown", "plantuml" }
            vim.g.mkdp_preview_options = vim.empty_dict()
            vim.g.mkdp_preview_options.uml = { imageFormat = "svg", server = vim.g.puml_server }
            -- vim.g.mkdp_markdown_css = vim.fn.stdpath("config") .. "/assets/mkdp.css"
        end,
    },

    -- Gentoo and portage related syntax highlighting, filetype, and indent settings for vim
    { "gentoo/gentoo-syntax" },

}
