-- Configure Vim diagnostics
local function configure_diagnostics()
    for type, icon in pairs(require("config.icons").diagnostics) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end

    vim.diagnostic.config({
        underline = true,
        virtual_text = false,
        float = false,
        {
            source = "always",
            border = "single",
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        },
        signs = true,
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

    -- Neovim is very slow with dynamic file watching
    -- https://github.com/neovim/neovim/pull/23190
    -- https://github.com/neovim/neovim/issues/23291
    local nvim_slow = { workspace = { didChangeWatchedFiles = { dynamicRegistration = false }}}

    -- Update capabilities with those of cmp_nvim_lsp and what other plugins offer
    return vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities(),
        ufo_caps,
        nvim_slow
    )
end


return {

    -- nvim-lsp configuration
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            -- LSP lua symbols for nvim config development
            { "folke/neodev.nvim", config = true },
            "mason.nvim",
            "nvim-treesitter",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "lspsaga.nvim",
        },
        config = function()
            -- Configure lsp diagnostics
            configure_diagnostics()

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
                    b.formatting.black.with({ extra_args = { "--fast" } }),
                    b.formatting.isort,
                    b.formatting.shfmt,
                    b.formatting.stylua.with({
                        condition = function(utils)
                            return utils.root_has_file({"stylua.toml"})
                        end,
                    }),

                    b.diagnostics.markdownlint,
                    b.diagnostics.shellcheck,
                    b.diagnostics.flake8,
                },
            }
        end,
    },

    -- ltex-ls enhanced integration for neovim
    {
        "vigoux/ltex-ls.nvim",
        ft = { "markdown", "gitcommit", "text" },
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
                            local fullpath = vim.fs.normalize(file, ":p")
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
            scroll_preview = {
                scroll_down = "<C-Down>",
                scroll_up = "<C-Up>",
            },
            finder = {
                keys = {
                    expand_or_jump = { "o", "<CR>" },
                    vsplit = "s",
                    split = "S",
                    tabe = "t",
                    quit = { "q", "<ESC>" },
                },
            },
            definition = {
                edit = "<CR>",
                vsplit = "<C-v>",
                split = "<C-x>",
                tabe = "<C-t>",
                quit = { "q", "<Esc>" },
            },
            code_action = {
                show_server_name = true,
                keys = {
                    quit = { "q", "<Esc>" },
                    exec = "<CR>",
                },
            },
            lightbulb = {
                enable = true,
                enable_in_insert = false,
                sign = true,
                virtual_text = false,
            },
            diagnostic = {
            },
            rename = {
                quit = { "<C-c>", "<Esc>" },
            },
            outline = {
                keys = {
                    expand_or_jump = { "o", "<CR>" },
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
