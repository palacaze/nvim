
-- Configuration table for the supported LSP servers
return {
    pylsp = {
        executable = "pylsp",
        config = {
            settings = {
                pylsp = {
                    plugins = {
                        flake8 = { enabled = false },
                        pylint = { enabled = false, args = { "--jobs=0" } },
                        pyflakes = { enabled = false },
                        pycodestyle = { enabled = false },
                        mccabe = { enabled = false },
                        rope_completion = { enabled = false }, -- ultra slow
                        jedi_completion = { enabled = true, fuzzy = false },
                        jedi_hover = { enabled = true },
                        jedi_references = { enabled = true },
                        jedi_signature_help = { enabled = true },
                        jedi_symbols = { enabled = true, all_scopes = true },
                    },
                },
            },
            root_dir = require("lspconfig.util").find_git_ancestor,
            flags = {
                debounce_text_changes = 200,
            },
        },
    },

    -- basedpyright = {
    --     executable = "basedpyright-langserver",
    --     config = {
    --         settings = {
    --             basedpyright = {
    --                 analysis = {
    --                     autoSearchPaths = true,
    --                     diagnosticMode = "openFilesOnly",
    --                     useLibraryCodeForTypes = true,
    --                 }
    --             }
    --         },
    --     }
    -- },

    clangd = {
        executable = "clangd",
        config = {
            capabilities = { offsetEncoding = { "utf-16" } },
            filetypes = { "c", "cpp" },
            root_dir = require("lspconfig.util").root_pattern(".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", ".git"),
            flags = {
                debounce_text_changes = 500,
            },
            cmd = {
                "clangd",
                "--log=error",
                "--enable-config",
                "--background-index",
                "--clang-tidy",
                "--header-insertion=never",
                "--completion-style=detailed",
                "--function-arg-placeholders",
                "--all-scopes-completion",
                "--pch-storage=memory",
            },
            init_options = {
                usePlaceholders = true,
                completeUnimported = true,
                clangdFileStatus = true,
            },
        },
    },

    neocmake = {
        executable = "neocmakelsp",
        config ={
            init_options = {
                builddirectory = ".sbuild"
            }
        }
    },

    lua_ls = {
        executable = "lua-language-server",
        setup = function()
            require("lazydev")
        end,
        config = {
            settings = {
                Lua = {
                    runtime = { version = "LuaJIT" },
                    completion = { callSnippet = "Replace" },
                    workspace = { checkThirdParty = false },
                    telemetry = { enable = false },
                },
            },
        }
    },

    bashls = {
        executable = "bash-language-server",
    },

    jsonls = {
        executable = "vscode-json-language-server",
    },

    gopls = {
        executable = "gopls",
    },

    marksman = {
        executable = "marksman",
    },

    ruff = {
        executable = "ruff",
        config = {
            init_options = {
                settings = {
                    configurationPreference = "filesystemFirst",
                    lineLength = 120,
                    -- Any extra CLI arguments for `ruff` go here.
                    args = {},
                },
            },
        },
    },

    rust_analyzer = {
        executable = "rust_analyzer",
    },

    zls = {
        executable = "zls",
    },
}
