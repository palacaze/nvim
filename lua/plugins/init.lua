local fn = vim.fn

-- Bootstrap packer package manager if absent
local ensure_packer = function()
    local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
        vim.cmd([[packadd packer.nvim]])
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()
local packer = require("packer")

packer.init({
    enable = true,
    threshold = 0,
    max_jobs = 20,
    display = {
        open_fn = function()
            return require("packer.util").float({ border = "rounded" })
        end,
    },
})

-- load dedicated plugin config
local function get_config(name)
    return string.format('require("plugins/config/%s")', name)
end

-- declare plugins
return packer.startup(function(use)
    use({
        -- Packer can manage itself
        "wbthomason/packer.nvim",
        -- Speed up loading Lua modules in Neovim to improve startup time
        "lewis6991/impatient.nvim",
        -- All the lua functions I don't want to write twice
        "nvim-lua/plenary.nvim",
    })

    -- Snippet engine, needed for nvim-cmp and snippet template
    use({
        "L3MON4D3/LuaSnip",
        -- event = { "InsertEnter" },
        requires = {
            "rafamadriz/friendly-snippets",
            event = { "InsertEnter" },
        },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    })

    -- Neovim UI Enhancer
    use({
        "stevearc/dressing.nvim",
        config = get_config("dressing"),
    })

    -- Smarter Splits
    use({
        "mrjones2014/smart-splits.nvim",
        config = get_config("smart-splits"),
    })

    -- Native and faster C implementation of fzf
    use({
        "nvim-telescope/telescope-fzf-native.nvim",
        run = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
    })

    -- Find, Filter, Preview, Pick. All lua, all the time
    use({
        "nvim-telescope/telescope.nvim",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-fzf-native.nvim",
        },
        config = get_config("telescope"),
    })

    -- Auto-completion engine
    use({
        "hrsh7th/nvim-cmp",
        after = { "LuaSnip" },
        requires = {
            { "hrsh7th/cmp-nvim-lsp", after = "nvim-cmp" },
            { "hrsh7th/cmp-nvim-lua", after = "nvim-cmp" },
            { "hrsh7th/cmp-path", after = "nvim-cmp" },
            { "hrsh7th/cmp-buffer", after = "nvim-cmp" },
            { "hrsh7th/cmp-cmdline", after = "nvim-cmp" },
            { "ray-x/lsp_signature.nvim", after = "nvim-cmp" },
            { "saadparwaiz1/cmp_luasnip", after = { "nvim-cmp", "LuaSnip" } },
        },
        config = get_config("nvim-cmp"),
    })

    -- mason automatic lsp & other tools installation
    use({
        "williamboman/mason-lspconfig.nvim",
        requires = "williamboman/mason.nvim",
    })

    -- nvim-lsp configuration (it relies on cmp-nvim-lsp, so it should be loaded after cmp-nvim-lsp).
    use({
        "neovim/nvim-lspconfig",
        after = { "cmp-nvim-lsp", "mason-lspconfig.nvim", "null-ls.nvim", "telescope.nvim" },
        config = get_config("lsp"),
        requires = {
            {
                "j-hui/fidget.nvim",
                config = function()
                    require("fidget").setup()
                end,
            },
        },
    })

    -- Tree Sitter
    use({
        "nvim-treesitter/nvim-treesitter",
        event = "BufEnter",
        run = ":TSUpdate",
        config = get_config("treesitter"),
    })

    -- A pretty diagnostics, references, telescope results, quickfix and location list
    use({
        "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
        config = get_config("trouble"),
    })

    -- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua
    -- configured by lsp
    use({
        "jose-elias-alvarez/null-ls.nvim",
        config = get_config("null-ls"),
    })

    -- Indent guides for Neovim
    use({
        "lukas-reineke/indent-blankline.nvim",
        config = get_config("indent-blankline"),
    })

    -- Ultra fold in Neovim
    -- use({
    --     "kevinhwang91/nvim-ufo",
    --     requires = "kevinhwang91/promise-async",
    --     config = get_config("ufo"),
    -- })

    -- File explorer
    use({
        "nvim-neo-tree/neo-tree.nvim",
        requires = { "MunifTanjim/nui.nvim" },
        config = get_config("neo-tree"),
    })

    -- A snazzy buffer line
    use({
        "akinsho/bufferline.nvim",
        tag = "v2.*",
        requires = "kyazdani42/nvim-web-devicons",
        config = get_config("bufferline"),
    })

    -- Statusline
    use({
        "nvim-lualine/lualine.nvim",
        requires = {
            "kyazdani42/nvim-web-devicons",
            "rlch/github-notifications.nvim",
        },
        after = { "nightfox.nvim" },
        config = get_config("lualine"),
    })

    -- LSP Symbols
    use({
        "stevearc/aerial.nvim",
        after = { "nvim-treesitter", "nvim-lspconfig" },
        config = get_config("aerial"),
    })

    -- Highlight, list and search todo comments in your projects
    use({
        "folke/todo-comments.nvim",
        config = function()
            require("todo-comments").setup()
        end,
    })

    -- Smooth escaping
    use({
        "max397574/better-escape.nvim",
        event = "InsertCharPre",
        config = get_config("better-escape"),
    })

    -- A neovim lua plugin to help easily manage multiple terminal windows
    use({
        "akinsho/toggleterm.nvim",
        config = get_config("toggleterm"),
    })

    -- Which key is that? Which-key!
    use({
        "folke/which-key.nvim",
        config = function()
            require("which-key").setup()
        end,
    })

    -- Highlight colours (sometimes, currently)
    use({
        "xiyaowong/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup({
                html = { mode = "foreground" },
                "css",
                "conf",
            })
        end,
    })

    -- colorschemes
    use({
        {
            "ellisonleao/gruvbox.nvim",
            config = get_config("gruvbox"),
        }, {
            "EdenEast/nightfox.nvim",
            config = get_config("nightfox"),
        }, {
            "Mofiqul/dracula.nvim",
            config = get_config("dracula"),
        }, {
            "lifepillar/vim-gruvbox8"
        }, {
            "rmehri01/onenord.nvim",
            config = get_config("onenord"),
        }, {
            "catppuccin/nvim",
            as = "catppuccin",
            config = get_config("catppuccin"),
        },
        config = get_config("colors")
    })

    --  Quoting/parenthesizing made simple
    use("tpope/vim-surround")

    -- Handle big files
    use("jreybert/vim-largefile")

    -- Binary editor
    use("shougo/vinarise.vim")

    -- EditorConfig plugin for Neovim
    use("gpanders/editorconfig.nvim")

    -- fugitive.vim: a Git wrapper so awesome, it should be illegal
    use("tpope/vim-fugitive")
    use("junegunn/gv.vim")

    -- Automatic insertion and deletion of a pair of characters
    use({
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({
                disable_filetype = { "TelescopePrompt", "guihua", "guihua_rust", "clap_input" },
            })
        end,
        after = "nvim-cmp",
    })

    -- Git changes in the gutter
    use({
        "lewis6991/gitsigns.nvim",
        config = get_config("gitsigns"),
        requires = "nvim-lua/plenary.nvim",
    })

    -- Smart and powerful comment plugin for neovim
    use({
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end,
    })

    -- Syntax highlighting, matching rules and mappings for the original Markdown and extensions
    use({
        "preservim/vim-markdown",
        requires = "godlygeek/tabular",
    })

    -- Pandoc integration and utilities for vim
    -- use("vim-pandoc/vim-pandoc")
    -- use("vim-pandoc/vim-pandoc-syntax")

    -- Go development plugin for Vim
    use({
        "ray-x/go.nvim",
        config = function()
            require("go").setup()
        end,
        requires = {
            { "ray-x/guihua.lua", run = "cd lua/fzy && make" },
        },
    })

    -- Python indent (follows the PEP8 style)
    use({ "Vimjas/vim-python-pep8-indent", ft = { "python" } })

    -- Python-related text object
    use({ "jeetsukumaran/vim-pythonsense", ft = { "python" } })

    -- Extended Vim syntax highlighting for C and C++
    use("bfrg/vim-cpp-modern")

    -- Vim configuration for Zig
    use("ziglang/zig.vim")

    -- Gentoo and portage related syntax highlighting, filetype, and indent settings for vim
    use("gentoo/gentoo-syntax")

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require("packer").sync()
    end
end)
