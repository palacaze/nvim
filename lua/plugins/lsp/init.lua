-- Configure Vim diagnostics
local function configure_diagnostics()
    local icons = require("config.icons").diagnostics
    vim.diagnostic.config({
        underline = true,
        virtual_text = false,
        float = false,
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = icons["Error"],
                [vim.diagnostic.severity.WARN] = icons["Warn"],
                [vim.diagnostic.severity.INFO] = icons["Info"],
                [vim.diagnostic.severity.HINT] = icons["Hint"],
            },
            -- no linehl, it is too intrusive
            numhl = {
                [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
                [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
                [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
                [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
            },
        },
        update_in_insert = false,
        severity_sort = true,
    })
end

-- Display the diagnostics for the current line in a floating window
local function hover_diagnostics(bufnr)
    vim.api.nvim_create_autocmd("CursorHold", {
        buffer = bufnr,
        callback = function()
            local opts = {
                focusable = false,
                close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                border = "single",
                source = "always",
                prefix = " ",
            }

            if not vim.b.diagnostics_pos then
                vim.b.diagnostics_pos = { nil, nil }
            end

            local cursor_pos = vim.api.nvim_win_get_cursor(0)
            if
                (cursor_pos[1] ~= vim.b.diagnostics_pos[1] or cursor_pos[2] ~= vim.b.diagnostics_pos[2])
                and #vim.diagnostic.get() > 0
            then
                vim.diagnostic.open_float(nil, opts)
            end

            vim.b.diagnostics_pos = cursor_pos
        end,
    })
end

-- Execute a function(client, buffer) when lsp client gets attached to a buffer
local function on_attach(attached_func)
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            local buffer = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            return attached_func(client, buffer) or false
        end,
    })
end

local function make_client_capabilities()
    -- UFO needs those for improved folding
    local ufo_caps = {
        textDocument = {
            foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
            },
        },
    }

    -- Update capabilities with those of cmp_nvim_lsp and what other plugins offer
    return vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        -- require("cmp_nvim_lsp").default_capabilities(),
        ufo_caps
    )
end


return {

    {
        "rachartier/tiny-inline-diagnostic.nvim",
        lazy = true,
        event = "BufEnter",  -- VeryLazy and LspAttach do not work
        init = function()
            configure_diagnostics()
        end,
        opts = {
            options = {
                show_source = false,
                multiple_diag_under_cursor = true,
                format = function(diag)
                    if diag.code then
                        return  diag.message .. " [" .. diag.code .. "]"
                    else
                        return diag.message
                    end
                end,
            },
        },
        config = function(_, opts)
            require("tiny-inline-diagnostic").setup(opts)
            vim.diagnostic.config({
                update_in_insert = false,
                severity_sort = true,
            })
        end
    },

    -- nvim-lsp configuration
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            -- LSP lua symbols for nvim config development
            { "folke/lazydev.nvim", config = true },
            "mason.nvim",
            "nvim-treesitter",
            "williamboman/mason-lspconfig.nvim",
            -- "hrsh7th/cmp-nvim-lsp",
            "lspsaga.nvim",
        },
        config = function()
            -- Configure lsp diagnostics
            -- configure_diagnostics()

            -- Configure functions to be executed on lsp client attaching to a buffer
            on_attach(function(client, buffer)
                require("plugins.lsp.mappings").on_attach(client, buffer)
            end)

            -- Configure servers
            local servers = require("plugins.lsp.servers")

            -- server configuration functon
            local function setup_server(name, server)
                if vim.fn.executable(server.executable) > 0 then
                    if vim.tbl_get(server, "setup") then
                        server.setup()
                    end

                    local server_opts = vim.tbl_deep_extend("force", {
                        single_file_support = true,
                        capabilities = make_client_capabilities()
                    }, server.config or {})

                    require("lspconfig")[name].setup(server_opts)
                end
            end

            -- configure all the servers known to us
            for name, server in pairs(servers) do
                setup_server(name, server)
            end
        end,
    },

    -- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua
    {
        "nvimtools/none-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "mason.nvim", "plenary.nvim" },
        opts = function()
            local nls = require("null-ls")
            local b = nls.builtins

            return {
                save_after_format = false,
                root_dir = require("null-ls.utils").root_pattern(".git"),
                sources = {
                    -- b.formatting.black.with({ extra_args = { "--fast" } }),
                    -- b.formatting.isort,
                    -- b.formatting.shfmt,
                    b.diagnostics.mypy,
                    b.formatting.stylua.with({
                        condition = function(utils)
                            return utils.root_has_file({"stylua.toml"})
                        end,
                    }),

                    b.diagnostics.markdownlint,
                },
            }
        end,
    },

    -- ltex-ls enhanced integration for neovim
    {
        "vigoux/ltex-ls.nvim",
        ft = { "markdown", "gitcommit", "text" },
        enabled = false,
        dependencies = { "nvim-lspconfig" },
        opts = {
            use_spellfile = false,
            filetypes = { "markdown", "gitcommit", "text" },
            on_attach = function(client, bufnr)
                require("plugins.lsp.mappings").on_attach(client, bufnr)
            end,
            capabilities = make_client_capabilities(),
            settings = {
                ltex = {
                    enabled = { "markdown", },
                    language = "auto",
                    diagnosticSeverity = "information",
                    sentenceCachesize = 2000,
                    additionalRules = {
                        enablePickyRules = true,
                    },
                    disabledRules = {
                        fr = { "APOS_TYP", "FRENCH_WHITESPACE" },
                    },
                    dictionary = (function()
                        -- For dictionary, search for files in the runtime to have
                        -- and include them as externals the format for them is
                        -- dict/{LANG}.txt
                        --
                        -- Also add dict/default.txt to all of them
                        local files = {}
                        for _, file in ipairs(vim.api.nvim_get_runtime_file("dict/*", true)) do
                            local lang = vim.fn.fnamemodify(file, ":t:r")
                            local fullpath = vim.uv.fs_realpath(file)
                            files[lang] = { ":" .. fullpath }
                        end

                        if files.default then
                            for lang, _ in pairs(files) do
                                if lang ~= "default" then
                                    vim.list_extend(files[lang], files.default)
                                end
                            end
                            files.default = nil
                        end
                        return files
                    end)(),
                },
            },
        },
    },

    -- LSP helper plugins
    {
        "ray-x/lsp_signature.nvim",
        lazy = true,
        init = function()
            on_attach(function(_, bufnr)
                require("lsp_signature").on_attach({
                    bind = true,
                    fix_pos = false,
                    floating_window = false,
                    floating_window_above_cur_line = true,
                    hint_enable = false,
                    always_trigger = false,
                    transparency = 0,
                    toggle_key = "<M-k>",
                    toggle_key_flip_floatwin_setting = true,
                    select_signature_key = "<M-n>",
                }, bufnr)
            end)
        end
    },

    -- Server progress information
    {
        "j-hui/fidget.nvim",
        event = "LspAttach",
        branch = "legacy",
        opts = {
            text = {
                spinner = "dots",
                done = " ",
            },
            window = { blend = 100 },
            fmt = {
                max_messages = 1,
            },
        },
    },

    -- UI for LSP
    {
        "glepnir/lspsaga.nvim",
        branch = "main",
        event = "LspAttach",
        opts = {
            definition = {
                keys = {
                    edit = '<C-c>o',
                    vsplit = '<C-c>v',
                    split = '<C-c>i',
                    tabe = '<C-c>t',
                    quit = 'q',
                    close = '<C-c>k',
                },
            },
            scroll_preview = {
                scroll_down = "<C-Down>",
                scroll_up = "<C-Up>",
            },
            finder = {
                default = "def+ref+impl",
                keys = {
                    toggle_or_open = { "o", "<CR>" },
                    vsplit = "s",
                    split = "S",
                    tabe = "t",
                    quit = { "q", "<ESC>" },
                },
            },
            code_action = {
                show_server_name = true,
                extend_gitsigns = true,
                keys = {
                    quit = { "q", "<Esc>" },
                    exec = "<CR>",
                },
            },
            lightbulb = {
                enable = false,
                enable_in_insert = false,
                sign = false,
                virtual_text = false,
            },
            diagnostic = {
            },
            rename = {
                quit = { "<C-c>", "<Esc>" },
            },
            outline = {
                keys = {
                    toggle_or_jump = "o",
                    jump = "<CR>",
                },
            },
            callhierarchy = {
                edit = "o",
                vsplit = "s",
                split = "S",
                tabe = "t",
                jump = "<CR>",
                quit = "q",
            },
            symbol_in_winbar = {
                -- FIXME: winbar is broken as per https://github.com/neovim/neovim/issues/19464
                enable = false,
            },
            ui = {
                border = "single",
                winblend = 10,
            },
        },
    },

}
