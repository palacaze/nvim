return {
    {
        "JoosepAlviste/nvim-ts-context-commentstring",
        init = function()
            vim.g.skip_ts_context_commentstring_module = true
        end,
        opts = {
            enable_autocmd = false,
            disable = { "json" },
        },
        main = "ts_context_commentstring",
    },

    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        keys = {
            { "<CR>", desc = "Increment selection", mode = { "o", "x" } },
            { "<BS>", desc = "Decrement selection", mode = { "o", "x" } },
            { ".", desc = "Smart select (textsubject)", mode = { "o", "x" } },
            { ";", desc = "Select outer (textsubject)", mode = { "o", "x" } },
            { "i;", desc = "Select inner (textsubject)", mode = { "o", "x" } },
            { ",", desc = "Previous selection (textsubject)", mode = { "o", "x" } },
        },
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "RRethy/nvim-treesitter-textsubjects",
            "vim-matchup",
        },
        opts = {
            ensure_installed = {
                "bash",
                "c",
                "cmake",
                -- "comment",  -- Don't install this, very very slow
                "cpp",
                "css",
                "cuda",
                "diff",
                "dockerfile",
                "dot",
                -- "doxygen",  -- Don't install this, very very slow
                "git_config",
                "git_rebase",
                "gitattributes",
                "gitcommit",
                "gitignore",
                "glsl",
                "go",
                "html",
                "hyprlang",
                "ini",
                "javascript",
                "json",
                "just",
                "kdl",
                "lua",
                "make",
                "markdown",
                "markdown_inline",
                "query",
                "proto",
                "python",
                "rasi",
                "regex",
                "rst",
                "rust",
                "sql",
                "tmux",
                "toml",
                "vim",
                "vimdoc",
                "yaml",
                "zig",
            },
            ignore_install = {},
            autopairs = {
                enable = true,
            },
            highlight = {
                enable = true,
                language_tree = false,
                disable = function(_, buf)
                    local max_filesize = 1024 * 1024
                    local sok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
                    return sok and stats and stats.size > max_filesize
                end,
                additional_vim_regex_highlighting = false,
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<CR>",
                    node_incremental = "<CR>",
                    scope_incremental = false,
                    node_decremental = "<BS>",
                },
            },
            indent = {
                enable = false,
            },
            conceal = {
                enable = true,
                disable = { "json", "markdown" },
            },
            matchup = {
                enable = true,
            },
            textsubjects = {
                enable = false,
                prev_selection = ",",
                keymaps = {
                    ["<CR>"] = "textsubjects-smart",
                    [";"] = "textsubjects-container-outer",
                    ["i;"] = "textsubjects-container-inner",
                },
            },
            textobjects = {
                disable = {},
                lookahead = true,
                select = {
                    enable = true,
                    disable = { "json" },
                    keymaps = {
                        ["af"] = { query = "@function.outer", desc = "Outer part of a function" },
                        ["if"] = { query = "@function.inner", desc = "Inner part of a function" },
                        ["ac"] = { query = "@class.outer", desc = "Outer part of a class" },
                        ["ic"] = { query = "@class.inner", desc = "Inner part of a class" },
                        ["aC"] = { query = "@comment.outer", desc = "Outer part of a comment" },
                        ["al"] = { query = "@loop.outer", desc = "Outer part of a loop" },
                        ["il"] = { query = "@loop.inner", desc = "Inner part of a loop" },
                        ["aP"] = { query = "@parameter.outer", desc = "Outer part of a parameter" },
                        ["iP"] = { query = "@parameter.inner", desc = "Inner part of a parameter" },
                        ["aS"] = { query = "@statement.outer", desc = "Outer part of a statement" },
                    },
                    selection_modes = {
                        ["@function.outer"] = "V",
                        ["@class.outer"] = "V",
                        ["@comment.outer"] = "V",
                        ["@loop.outer"] = "V",
                    },
                },
                swap = {
                    enable = true,
                    swap_next = {
                        ["<leader>sa"] = "@parameter.inner",
                        ["<leader>fa"] = "@function.inner",
                    },
                    swap_previous = {
                        ["<leader>sA"] = "@parameter.inner",
                        ["<leader>sF"] = "@function.inner",
                    },
                },
                move = {
                    enable = true,
                    disable = {},
                    set_jumps = true,
                    goto_next_start = {
                        ["]m"] = { query = "@function.outer", desc = "Next function start" },
                        ["]]"] = { query = "@class.outer", desc = "Next class start" },
                    },
                    goto_next_end = {
                        ["]M"] = { query = "@function.outer", desc = "Next function end" },
                        ["]["] = { query = "@class.outer", desc = "Next class end" },
                    },
                    goto_previous_start = {
                        ["[m"] = { query = "@function.outer", desc = "Previous function start" },
                        ["[["] = { query = "@class.outer", desc = "Previous class start" },
                    },
                    goto_previous_end = {
                        ["[M"] = { query = "@function.outer", desc = "Previous function end" },
                        ["[]"] = { query = "@class.outer", desc = "Previous class end" },
                    },
                },
            },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
            vim.treesitter.query.set("javascript", "injections", "")
            vim.treesitter.query.set("lua", "injections", "")

            vim.filetype.add({ pattern = { [".*/hypr/.*%.conf"] = "hyprlang" } })
        end,
    },
}
