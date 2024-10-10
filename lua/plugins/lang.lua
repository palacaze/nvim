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

    {
        "linux-cultist/venv-selector.nvim",
        branch = "regexp",
        lazy = true,
        dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap-python" },
        opts = {
            -- Your options go here
            -- name = "venv",
            -- auto_refresh = false
        },
        keys = {
            -- Keymap to open VenvSelector to pick a venv.
            { "<leader>vs", "<cmd>VenvSelect<cr>" },
            -- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
            { "<leader>vc", "<cmd>VenvSelectCached<cr>" },
        },
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

    -- Format markdown tables
    {
        "Kicamon/markdown-table-mode.nvim",
        enabled = false,
        config = true,
    },

    -- Pretty formatting of markdown documents
    {
        "OXY2DEV/markview.nvim",
        enabled = false,
        lazy = false,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons"
        },
        opts = {
            modes = { "n", "no", "c" },
            hybrid_modes = { },
            -- callbacks = {
            --     on_enable = function(_, win)
            --         vim.wo[win].conceallevel = 2
            --         vim.wo[win].concealcursor = "nc"
            --     end,
            --     on_disable = function(_, win)
            --         vim.wo[win].conceallevel = 0
            --         vim.wo[win].concealcursor = ""
            --     end,
            -- },
        },
        config = function(_, opts)
            local markview = require("markview")
            local presets = require("markview.presets")
            opts.headings = presets.headings.glow_labels
            markview.setup(opts)
        end,
    },

    {
        "MeanderingProgrammer/render-markdown.nvim",
        enabled = true,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "echasnovski/mini.icons",
        },
        lazy = true,
        ft = { "markdown" },
        opts = {
            -- heading = {
                -- backgrounds = { "markdownH1", "markdownH2", "markdownH3", "markdownH4", "markdownH5", "markdownH6" },
            -- },
            code = {
                width = "block",
                right_pad = 4,
                min_width = 50,
                position = "right",
                sign = false,
            },
            heading = {
                width = "block",
                right_pad = 4,
                -- min_width = 30,
            },
            win_options = {
                conceallevel = {
                    default = 0,
                    rendered = 2,
                },
            },
        },
    },

    {
        "iamcco/markdown-preview.nvim",
        ft = { "markdown", "plantuml" },
        build = "cd app && npm install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown", "plantuml" }
            vim.g.mkdp_preview_options = vim.empty_dict()
            vim.g.mkdp_preview_options.disable_sync_scroll = 1
            vim.g.mkdp_preview_options.uml = { imageFormat = "svg", server = vim.g.puml_server }
            -- vim.g.mkdp_markdown_css = vim.fn.stdpath("config") .. "/assets/mkdp.css"
        end,
    },

    {
        "Civitasv/cmake-tools.nvim",
        enabled = false,
        enabled = true,
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
            cmake_generate_options = {},
            cmake_regenerate_on_save = false,
            cmake_soft_link_compile_commands = false,
            cmake_compile_commands_from_lsp = false,
            cmake_build_directory = "build/out/${variant:buildType}",
        },
    },

    {
        "p00f/godbolt.nvim",
        ft = { "cpp", "c" },
        cmd = { "Godbolt", "GodboltCompiler" },
        opts = {
            languages = {
                cpp = { compiler = "g131", options = { userArguments = "-W -Wall -O3 -std=c++20" } },
            },
            quickfix = {
                enable = true,
                auto_open = true,
            },
        },
    },

    -- Gentoo and portage related syntax highlighting, filetype, and indent settings for vim
    { "gentoo/gentoo-syntax" },

}
