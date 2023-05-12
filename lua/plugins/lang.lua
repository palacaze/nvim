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

    {
        "iamcco/markdown-preview.nvim",
        ft = { "markdown", "plantuml" },
        build = "cd app && npm install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown", "plantuml" }
        end,
    },

    -- Gentoo and portage related syntax highlighting, filetype, and indent settings for vim
    { "gentoo/gentoo-syntax" },

    -- Syntax highlighting, matching rules and mappings for the original Markdown and extensions
    -- {
    --    "preservim/vim-markdown",
    --    ft = "markdown",
    --    init = function()
    --        vim.g.vim_markdown_auto_insert_bullets = 1
    --        vim.g.vim_markdown_autowrite = 1
    --        vim.g.vim_markdown_conceal = 2
    --        vim.g.vim_markdown_conceal_code_blocks = 0
    --        vim.g.vim_markdown_edit_url_in = "tab"
    --        vim.g.vim_markdown_emphasis_multiline = 1
    --        vim.g.vim_markdown_follow_anchor = 1
    --        vim.g.vim_markdown_frontmatter = 1
    --        vim.g.vim_markdown_frontmatter = 1
    --        vim.g.vim_markdown_json_frontmatter = 1
    --        vim.g.vim_markdown_math = 1
    --        vim.g.vim_markdown_new_list_item_indent = 1
    --        vim.g.vim_markdown_strikethrough = 1
    --        vim.g.vim_markdown_toml_frontmatter = 1
    --    end,
    -- }

}
