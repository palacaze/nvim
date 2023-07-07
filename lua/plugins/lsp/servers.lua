
-- Configuration table for the supported LSP servers
return {
    pylsp = {
        executable = "pylsp",
        config = {
            settings = {
                pylsp = {
                    plugins = {
                        pylint = { enabled = true, executable = "pylint" },
                        pyflakes = { enabled = true },
                        pycodestyle = { enabled = true },
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

    clangd = {
        executable = "clangd",
        config = {
            capabilities = { offsetEncoding = { "utf-16" } },
            root_dir = require("lspconfig.util").root_pattern(".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", ".git"),
            flags = {
                debounce_text_changes = 500,
            },
            cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--header-insertion=never",
                "--completion-style=detailed",
                "--function-arg-placeholders",
                "--fallback-style=llvm",
            },
            init_options = {
                usePlaceholders = true,
                completeUnimported = true,
                clangdFileStatus = true,
            },
        },
    },

    lua_ls = {
        executable = "lua-language-server",
        setup = function()
            require("neodev")
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

    gopls = {
        executable = "gopls",
    },

    marksman = {
        executable = "marksman",
    },

    rust_analyzer = {
        executable = "rust_analyzer",
    },

    zls = {
        executable = "zls",
    },
}
