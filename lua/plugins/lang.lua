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
        cmd = { "OpenBrowser", "OpenBrowserSearch" },
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

    {
        "Civitasv/cmake-tools.nvim",
        ft = { "cpp", "c", "cmake" },
        cmd = {
            "CMakeGenerate",
            "CMakeBuild",
            "CMakeRun",
            "CMakeDebug",
            "CMakeLaunchArgs",
            "CMakeSelectBuildType",
            "CMakeSelectBuildTarget",
            "CMakeSelectLaunchTarget",
            "CMakeSelectKit",
            "CMakeSelectConfigurePreset",
            "CMakeSelectBuildPreset",
            "CMakeOpen",
            "CMakeClose",
            "CMakeInstall",
            "CMakeClean",
            "CMakeStop",
            "CMakeQuickBuild",
            "CMakeQuickRun",
            "CMakeQuickDebug",
        },
        keys = {
            { "<Leader>cg", "<Cmd>CMakeGenerate<CR>", desc = "CMake Generate" },
            { "<Leader>cG", "<Cmd>CMakeGenerate!<CR>", desc = "CMake Generate (clean)" },
            { "<Leader>cb", "<Cmd>CMakeBuild<CR>", desc = "CMake Build" },
            { "<Leader>cB", "<Cmd>CMakeQuickBuild<CR>", desc = "CMake Build (choose)" },
            { "<Leader>cC", "<Cmd>CMakeClean<CR>", desc = "CMake Clean" },
            { "<Leader>cd", "<Cmd>CMakeDebug<CR>", desc = "CMake Debug" },
            { "<Leader>cD", "<Cmd>CMakeQuickDebug<CR>", desc = "CMake Debug (choose)" },
            { "<Leader>cr", "<Cmd>CMakeRun<CR>", desc = "CMake Run" },
            { "<Leader>cR", "<Cmd>CMakeQuickRun<CR>", desc = "CMake Run (choose)" },
            { "<Leader>csb", "<Cmd>CMakeSelectBuildType<CR>", desc = "Cmake Select build type" },
            { "<Leader>csB", "<Cmd>CMakeSelectBuildTarget<CR>", desc = "Cmake Select build target" },
            { "<Leader>cst", "<Cmd>CMakeSelectLaunchTarget<CR>", desc = "Cmake Select launch target" },
            { "<Leader>csk", "<Cmd>CMakeSelectKit<CR>", desc = "Cmake Select kit" },
            { "<Leader>cspc", "<Cmd>CMakeSelectConfigurePreset<CR>", desc = "Cmake Select configure preset" },
            { "<Leader>cspb", "<Cmd>CMakeSelectBuildPreset<CR>", desc = "Cmake Select build preset" },
            { "<Leader>cc", "<Cmd>CMakeOpen<CR>", desc = "Cmake Toggle Open/Close" },
            { "<Leader>cK", "<Cmd>CMakeStop<CR>", desc = "Stop Cmake process" },
        },
        opts = {
            cmake_regenerate_on_save = false,
            cmake_soft_link_compile_commands = false,
            cmake_compile_commands_from_lsp = false,
            start_insert_in_launch_task = true,
            start_insert_in_other_tasks = true,
            cmake_always_use_terminal = false,
            cmake_quickfix_opts = {
                show = "only_on_error",
            },
        },
    },

    -- Gentoo and portage related syntax highlighting, filetype, and indent settings for vim
    { "gentoo/gentoo-syntax" },

}
